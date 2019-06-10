#DEFINE PROJ_ICON "GladeToBac.pixdata"
#DEFINE PRO_STR PROJ_NAME  & "(" & PROJ_VERS & ")"

#DEFINE STACK_NEW MKL(0) & CHR(1)
#DEFINE STACK_ANZ(_S_) *CAST(LONG PTR, _S_)
#DEFINE STACK_FIN(_S_, _P_) INSTR(5, _S_, CHR(1) & _P_ & CHR(1))
#DEFINE STACK_ADD(_S_, _P_) *CAST(LONG PTR, SADD(_S_)) += 1 : _S_ &= _P_ & CHR(1)

#DEFINE TIME_STAMP FORMAT(NOW, FormDa) & ", " & FORMAT(NOW, FormZe)

CONST SufUi = ".ui", _
     SufGla = ".glade", _
     SufBas = ".bas", _
      SufBi = ".bi", _
     SufPot = ".pot", _
     SufLiz = ".lic", _
     SufDes = ".desc", _
   SufTobac = "_tobac.bas", _
     SufGui = "_gui.bas", _
     NamMkf = "makefile", _
     NamRdm = "readme", _
     SufRdm = ".txt", _
     SufGea = ".geany", _
     SufIde = ".fbide.fbp", _
     SufEdi = ".fbp", _
     SufJel = ".jfp", _
     SufWin = ".rc", _
     FormJa = "yyyy", _
     FormDa = "yyyy-mm-dd", _
     FormZe = "hh:mm"

TYPE RepData
  DECLARE FUNCTION Az() AS LONG
  DECLARE FUNCTION add(BYREF T AS STRING, BYREF E AS STRING, _
                       BYVAL M AS LONG = 0) AS ZSTRING PTR
  DECLARE FUNCTION Po_(BYREF T AS STRING, BYVAL M AS LONG = 0) AS STRING
  DECLARE FUNCTION Rep(BYREF T AS STRING) AS ZSTRING PTR
  DECLARE FUNCTION fin(BYREF N AS LONG) AS STRING
  DECLARE SUB ForEach(BYVAL Cb AS FUNCTION(BYREF AS STRING, BYVAL AS ZSTRING PTR) AS LONG)
'Private:
  AS STRING Su = STACK_NEW, _
            Er
END TYPE

TYPE UserInt AS _UserInt

TYPE SigData
  AS RepData Sig
  DECLARE CONSTRUCTOR(BYVAL Ui AS UserInt PTR, BYREF F AS STRING)
  DECLARE SUB CheckMinus(BYREF N AS STRING)
  DECLARE FUNCTION Find(BYREF W AS STRING, BYREF N AS STRING) AS STRING
  DECLARE FUNCTION GenHandler(BYREF T AS STRING) AS STRING
Private:
  DECLARE SUB load()
  DECLARE FUNCTION readName(BYVAL Fnr AS LONG) AS STRING
  DECLARE FUNCTION readTyp(BYVAL Fnr AS LONG) AS STRING
  DECLARE FUNCTION readPar(BYVAL Fnr AS LONG) AS STRING
  DECLARE FUNCTION genParList(BYREF P AS STRING, BYREF T AS STRING) AS STRING
END TYPE

TYPE XmlData
  AS UserInt PTR _
       Ui
  AS STRING _
     Path, _
      Nam, _
      Suf, _
    LPath, _
    WPath, _
     Auth, _
     Mail, _
     Site, _
     Desc, _
     Vers, _
     TyNa, _
     GVer, _
     PLiz, _
     Jahr, _
     WiMa, _
      Ref = STACK_NEW
  AS gboolean _
      Bas : 1, _
      Gla : 1, _
     Toba : 1, _
     I18N : 1, _
     UiIn : 1
  AS RepData PTR _
      Han = NEW RepData
  DECLARE CONSTRUCTOR()
  DECLARE DESTRUCTOR()
  DECLARE SUB Init(BYREF F AS STRING, BYVAL Ui AS UserInt PTR)
  DECLARE SUB readXml()
  DECLARE SUB readBas()
  DECLARE SUB readIni(BYVAL Mo AS INTEGER = 0)
  DECLARE SUB saveIni()
  DECLARE FUNCTION GtkVers(BYREF T AS STRING) AS UINTEGER
  DECLARE FUNCTION GtkVersStr(BYREF T AS STRING, BYREF S AS STRING, _
                              BYVAL C AS INTEGER = 0) AS STRING
  DECLARE FUNCTION clearHandler(BYVAL Modus AS INTEGER) AS INTEGER
Private:
  AS STRING OkC = STRING(256, 3)
  DECLARE SUB checkHandlerName(BYREF S AS STRING, BYVAL Mo AS INTEGER = 0)
  DECLARE SUB findBas(BYREF Z AS STRING, BYREF W AS STRING, BYREF V AS STRING)
  DECLARE SUB findUin(BYREF Z AS STRING, BYREF W AS STRING, BYREF V AS LONG)
  DECLARE SUB findStr(BYREF Z AS STRING, BYREF W AS STRING, BYREF V AS STRING)
  DECLARE FUNCTION UserName (BYREF W AS STRING, BYREF N AS STRING) AS INTEGER
  DECLARE FUNCTION findVal(BYREF zeile AS STRING, BYREF wort AS STRING) AS STRING
  DECLARE SUB FileDa(BYREF N AS STRING, BYREF E AS STRING, BYVAL M AS INTEGER = 0)
  DECLARE SUB DataDa(BYREF T AS STRING, BYVAL N AS INTEGER, _
                     BYREF Z AS STRING, BYREF F AS STRING)
END TYPE

TYPE _UserInt
        AS SigData PTR Sig, _
                       Sig2, _
                       Sig3
        'AS XmlData PTR Xml = NEW XmlData()
        AS XmlData     Xml
        AS RepData     Liz
  AS gboolean NoGui : 1, _
              IsGui : 1, _
               Make : 1, _
             ReadMe : 1, _
              Geany : 1, _
              FbIde : 1, _
             FbEdit : 1, _
              Jelly : 1, _
                Win : 1, _
                 Rc : 1
   AS gint Brei, _
           Hoch, _
           Farb = COLOR
   AS STRING _
    OrdData = "data" _
   , S_Path = CURDIR
  DECLARE DESTRUCTOR()
  DECLARE FUNCTION Init() AS INTEGER
  DECLARE SUB Load(BYREF F AS STRING)
  DECLARE SUB Ausmisten(BYVAL Mo AS INTEGER = 0)
  DECLARE SUB GenBas()
  DECLARE SUB GenI18N()
  DECLARE SUB GenProj()
  DECLARE SUB _Get()
  DECLARE SUB RausClr(BYREF T AS STRING)
  DECLARE SUB Scrol(BYVAL Mo AS INTEGER = 0)
  DECLARE SUB Raus(BYREF T AS STRING, BYVAL Mo AS INTEGER = 0)
  DECLARE SUB RausRot(BYREF T AS STRING, BYVAL Mo AS INTEGER = 0)
  DECLARE SUB RausBlau(BYREF T AS STRING, BYVAL Mo AS INTEGER = 0)
  DECLARE FUNCTION Folder(BYREF T AS STRING) AS INTEGER
  DECLARE FUNCTION No(BYVAL M AS INTEGER, BYREF T AS STRING) AS INTEGER
  DECLARE FUNCTION Filename2utf8(BYREF File AS STRING) AS STRING
  DECLARE FUNCTION Antwort(BYREF F AS STRING, _
                           BYREF B1 AS STRING, _
                           BYREF B2 AS STRING, _
                           BYREF B3 AS STRING) AS INTEGER
Private:
   AS GtkTreeModel PTR SoMo
    AS GtkComboBox PTR ComBox
    AS GtkTextIter     Iter
    AS GtkTextView PTR TextView
  AS GtkTextBuffer PTR Buffer
  DECLARE SUB _set()
  DECLARE SUB initGUI()
  DECLARE SUB loadLiz()
  DECLARE SUB xget(BYREF C AS STRING, BYREF E AS STRING, BYREF J AS STRING)
  DECLARE SUB label_set_markup(BYREF W AS GObject PTR, BYREF T AS STRING)
  DECLARE SUB entry_set_text(BYREF W AS GObject PTR, BYREF T AS STRING)
  DECLARE FUNCTION dosTxt(BYREF T AS STRING) AS STRING
  DECLARE FUNCTION readIcon() AS GdkPixbuf PTR
END TYPE

DIM SHARED AS UserInt _UI_
DIM SHARED AS STRING _OUT_
