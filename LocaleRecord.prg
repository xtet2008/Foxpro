* Program Name : LocaleRecord.Prg
* Article No.  : [Win API] - 026
* Illustrate   : ??????????/????
* Date / Time  : 2001.09.25
* Writer       : 
* 1st Post     : 
* My Comment   :

* some LCTYPE constants
#DEFINE LOCALE_ILANGUAGE                1   && language id
#DEFINE LOCALE_SLANGUAGE                2   && localized name of language
#DEFINE LOCALE_SENGLANGUAGE          4097   && English name of language
#DEFINE LOCALE_SABBREVLANGNAME          3   && abbreviated language name
#DEFINE LOCALE_SNATIVELANGNAME          4   && native name of language
#DEFINE LOCALE_ICOUNTRY                 5   && country code
#DEFINE LOCALE_SCOUNTRY                 6   && localized name of country
#DEFINE LOCALE_SENGCOUNTRY           4098   && English name of country
#DEFINE LOCALE_SABBREVCTRYNAME          7   && abbreviated country name
#DEFINE LOCALE_SNATIVECTRYNAME          8   && native name of country
#DEFINE LOCALE_IDEFAULTLANGUAGE         9   && default language id
#DEFINE LOCALE_IDEFAULTCOUNTRY         10   && default country code
#DEFINE LOCALE_IDEFAULTCODEPAGE        11   && default oem code page
#DEFINE LOCALE_IDEFAULTANSICODEPAGE  4100   && default ansi code page
#DEFINE LOCALE_IDEFAULTMACCODEPAGE   4113   && default mac code page

#DEFINE LOCALE_ILDATE                  34   && long date format ordering
#DEFINE LOCALE_ILZERO                  18   && leading zeros for decimal
#DEFINE LOCALE_IMEASURE                13   && 0 = metric, 1 = US
#DEFINE LOCALE_IMONLZERO               39   && leading zeros in month field
#DEFINE LOCALE_INEGCURR                28   && negative currency mode
#DEFINE LOCALE_INEGSEPBYSPACE          87   && mon sym sep by space from neg amt

#DEFINE LOCALE_INEGSIGNPOSN            83   && negative sign position
* more constants exist...

    DECLARE INTEGER GetLocaleInfo IN kernel32;
        INTEGER  Locale,;
        INTEGER  LCType,;
        STRING @ lpLCData,;
        INTEGER  cchData

    CREATE CURSOR cs (;
        locale    N(6),;
        langid    C( 4),;
        llnagname C(30),;
        elangname C(30),;
        alangname C( 3),;
        nlangname C(30),;
        ccode     C( 3),;
        lcname    C(30),;
        ecname    C(30),;
        acname    C( 3),;
        ncname    C(30),;
        dlangid   C( 4),;
        dccode    C( 3),;
        doemcp    C( 5),;
        dansicp   C( 5),;
        dmaccp    C( 5),;
        ldtfmt    C( 2),;
        ldzeros   C( 2),;
        metrics   C( 2),;
        monzero   C( 2),;
        necurr    C( 2),;
        negsep    C( 2),;
        negsign   C( 2);
    )

    * scan top &H10000 codes
    * under WinNT 4.0 it returns 138 records
    * WinMe -- 164 records
    FOR ii=0 TO 65535
        = saveLInfo (ii)
    ENDFOR

    SELECT cs
    GO TOP
    BROW NORMAL NOWAIT
RETURN        && main

PROCEDURE  saveLInfo (lnLocale)
* saves one local record for the locale
    IF Len (getLInfo (lnLocale, LOCALE_ILANGUAGE)) = 0
    * exit if no information exists for this locale id
        RETURN
    ENDIF

    INSERT INTO cs VALUES (;
        lnLocale,;
        getLInfo (lnLocale, LOCALE_ILANGUAGE),;
        getLInfo (lnLocale, LOCALE_SLANGUAGE),;
        getLInfo (lnLocale, LOCALE_SENGLANGUAGE),;
        getLInfo (lnLocale, LOCALE_SABBREVLANGNAME),;
        getLInfo (lnLocale, LOCALE_SNATIVELANGNAME),;
        getLInfo (lnLocale, LOCALE_ICOUNTRY),;
        getLInfo (lnLocale, LOCALE_SCOUNTRY),;
        getLInfo (lnLocale, LOCALE_SENGCOUNTRY),;
        getLInfo (lnLocale, LOCALE_SABBREVCTRYNAME),;
        getLInfo (lnLocale, LOCALE_SNATIVECTRYNAME),;
        getLInfo (lnLocale, LOCALE_IDEFAULTLANGUAGE),;
        getLInfo (lnLocale, LOCALE_IDEFAULTCOUNTRY),;
        getLInfo (lnLocale, LOCALE_IDEFAULTCODEPAGE),;
        getLInfo (lnLocale, LOCALE_IDEFAULTANSICODEPAGE),;
        getLInfo (lnLocale, LOCALE_IDEFAULTMACCODEPAGE),;
        getLInfo (lnLocale, LOCALE_ILDATE),;
        getLInfo (lnLocale, LOCALE_ILZERO),;
        getLInfo (lnLocale, LOCALE_IMEASURE),;
        getLInfo (lnLocale, LOCALE_IMONLZERO),;
        getLInfo (lnLocale, LOCALE_INEGCURR),;
        getLInfo (lnLocale, LOCALE_INEGSEPBYSPACE),;
        getLInfo (lnLocale, LOCALE_INEGSIGNPOSN);
    )
RETURN

PROCEDURE  getLInfo (lnLocale, lnType)
* retrieves a value for the parameter of lnType for the locale lnLocale
    lcBuffer = SPACE(250)
    lnLength = GetLocaleInfo (lnLocale, lnType, @lcBuffer, Len(lcBuffer))
RETURN Iif (lnLength > 0, STRTRAN(LEFT(lcBuffer, lnLength-1), Chr(0)), "")