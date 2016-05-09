#include <winver.h>

LANGUAGE 0x09,0x01

1 VERSIONINFO
  FILEVERSION @MAJOR_VER@,@MINOR_VER@,@REL_VER@,@FIX_VER@
  PRODUCTVERSION @MAJOR_VER@,@MINOR_VER@,@REL_VER@,@FIX_VER@
  FILEFLAGSMASK 0x3fL
#ifdef _DEBUG
  FILEFLAGS 0x01L
#else
  FILEFLAGS 0x00L
#endif
  FILEOS VOS__WINDOWS32
  FILETYPE VFT_DLL
  FILESUBTYPE 0x0L
BEGIN
    BLOCK "StringFileInfo"
    BEGIN
	BLOCK "040904b0"
	BEGIN
	    // Required:	    
	    VALUE "CompanyName", "The OpenSSL Project, http://www.openssl.org/\0"
	    VALUE "FileDescription", "OpenSSL Shared Library\0"
	    VALUE "FileVersion", "@VERSION@\0"
#if defined(CRYPTO)
	    VALUE "InternalName", "libeay32\0"
	    VALUE "OriginalFilename", "libeay32.dll\0"
#elif defined(SSL)
	    VALUE "InternalName", "ssleay32\0"
	    VALUE "OriginalFilename", "ssleay32.dll\0"
#endif
	    VALUE "ProductName", "The OpenSSL Toolkit\0"
	    VALUE "ProductVersion", "@VERSION@\0"
	    // Optional:
	    //VALUE "Comments", "\0"
	    VALUE "LegalCopyright", "Copyright � 1998-2005 The OpenSSL Project. Copyright � 1995-1998 Eric A. Young, Tim J. Hudson. All rights reserved.\0"
	    //VALUE "LegalTrademarks", "\0"
	    //VALUE "PrivateBuild", "\0"
	    //VALUE "SpecialBuild", "\0"
	END
    END
    BLOCK "VarFileInfo"
    BEGIN
        VALUE "Translation", 0x409, 0x4b0
    END
END