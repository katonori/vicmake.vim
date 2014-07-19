import re
import commands
import tempfile
import os

gInstance = None
CMAKE_CACHE = "CMakeCache.txt"

class Vicmake():
    mVarList = []
    mInternalVarList = []
    mLogFilename = ""
    mNameCacheFilename = ""
    mValCacheFilename = ""
    mTypeCacheFilename = ""
    mInitDone = False
    mSrcDir = ""

    def __init__(self):
        self.mLogFilename = tempfile.NamedTemporaryFile()
        self.mNameCacheFilename = tempfile.NamedTemporaryFile()
        self.mValCacheFilename = tempfile.NamedTemporaryFile()
        self.mTypeCacheFilename = tempfile.NamedTemporaryFile()

    def ParseFile(self):
        self.mVarList = []
        self.mInternalVarList = []
        isStartInternal = False
        try:
            f = open(CMAKE_CACHE, "r")
        except Exception as e:
            raise e
        for l in f.readlines():
            m = re.search(r"^([a-zA-Z0-9_-]+):(\S+)=(.*)$", l)
            if m:
                name = m.group(1)
                type = m.group(2)
                val = m.group(3)
                if "CMAKE_HOME_DIRECTORY" == name:
                    self.mSrcDir = val
                if isStartInternal:
                    self.mInternalVarList.append((name, type, val))
                else:
                    self.mVarList.append((name, type, val))
            m = re.search(r"^# INTERNAL cache entries", l)
            if m:
                isStartInternal = True
        self.mInitDone = True

    def Dump(self):
        for v in self.mVarList:
            print "%s:%s\t\t%s"%(v[1], v[0], v[2])

    def RunCmake(self, dir):
        cmd = "cmake " + str(dir)
        (rv, out) = commands.getstatusoutput(cmd)
        self.ParseFile()
        self.InitEdit()

    def LoadCache(self):
        self.ParseFile()
        try:
            fval = open(self.GetValCacheFilename(), "w")
            fname = open(self.GetNameCacheFilename(), "w")
            ftype = open(self.GetTypeCacheFilename(), "w")
        except Exception as e:
            raise e

        for l in self.mVarList:
            fname.write("%s\n"%(l[0]))
            ftype.write("%s\n"%(l[1]))
            fval.write("%s\n"%(l[2]))

        fval.close()
        ftype.close()
        fname.close()
        return True

    def WritebackCache(self):
        try:
            fout = open(CMAKE_CACHE, "w")
            fval = open(self.mValCacheFilename.name, "r")
            fname = open(self.mNameCacheFilename.name, "r")
            ftype = open(self.mTypeCacheFilename.name, "r")
        except Exception as e:
            raise e

        linesVal = fval.readlines()
        linesName = fname.readlines()
        linesType = ftype.readlines()

        if len(linesName) != len(linesVal) or len(linesName) != len(linesType):
            return False

        i = 0
        while i < len(linesName):
            val = linesVal[i].replace("\n", "")
            type = linesType[i].replace("\n", "")
            name = linesName[i].replace("\n", "")
            fout.write("%s:%s=%s\n"%(name, type, val))
            i += 1 

        fout.write("# INTERNAL cache entries")
        for l in self.mInternalVarList:
            fout.write("%s:%s=%s\n"%(l))

        return True

    def RerunCmake(self):
        if not self.WritebackCache():
            return False

        cmd = "cmake " + self.mSrcDir
        (rv, out) = commands.getstatusoutput(cmd)
        return True

    def GetLogFilename(self):
        return self.mLogFilename.name

    def GetNameCacheFilename(self):
        return self.mNameCacheFilename.name

    def GetTypeCacheFilename(self):
        return self.mTypeCacheFilename.name

    def GetValCacheFilename(self):
        return self.mValCacheFilename.name

def GetInstance():
    global gInstance
    if os.path.exists(CMAKE_CACHE) == False:
        return None
    if gInstance == None:
        gInstance = Vicmake()
    return gInstance

if __name__ == "__main__":
    inst = GetInstance()
    inst.ParseFile()
    inst.RerunCmake("../")
