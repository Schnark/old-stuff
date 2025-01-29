/* mathe.c: Versuch einer Übersetzung von TeX nach HTML für WikiTaxi */
#include <stdio.h>
#include <string.h>
#include <ctype.h>

char math_closings[1024];	//alle noch zu schließenden HTML-Tags
int math_toclose;		//Anzahl der noch zu schließenden HTML-Tags
int math_braceclose;		//Anzahl der noch durch geschweifte Klammern zu schließenden HTML-Tags
int math_italics;		//0: Texte nicht kursiv

int math_getnext(char * ein, char * aus)
//Gibt den nächsten Befehl oder das nächste Zeichen aus
//Rückgabe: 0 für Zeichen, 1 für Befehl
{
 strncpy(aus, ein, 1); aus[1]='\0';		//erstes Zeichen kopieren...
 strcpy(ein, ein+1);		//...und löschen
 if (aus[0]=='\\') {		//falls ein Befehl
    strncat(aus, ein, 1);	//nächstes Zeichen kopieren...
    strcpy(ein, ein+1);		//...und löschen
    if (isalpha(aus[1])) {	//Buchstabe -> weiter bis zum ersten Nichtbuchstaben
       while (isalpha(ein[0])) {	//noch ein Buchstabe
             strncat(aus, ein, 1);
             strcpy(ein, ein+1);
       }
    }
    return 1;			//Rückgabe: Befehl
 } else 			//kein Befehl
    return 0;			//Rückgabe: Zeichen
}

void math_addclose(char * close)
//Fügt ein schließendes Tag an
{
 char hilfsstring [1024];
 strcpy(hilfsstring,close);
 if (math_toclose==math_braceclose) {strcat(hilfsstring,"@"); math_toclose++; }
 strcat(hilfsstring,math_closings); strcpy(math_closings,hilfsstring);
}


void math_getnextclose(char * close)
//Liest nächstes schließendes HTML-Tag aus, dekrementiert gleichzeitig math_toclose
{
 char * suche;
 char allclose [1024];
 char nextclose [16];
 strcpy(close,"");
 if (math_toclose==0) return;	//nichts zu schließen
 math_toclose--;
 suche = strchr(math_closings,'@'); //Endemarkierung suchen
 strncpy(allclose,math_closings,suche-math_closings); allclose[suche-math_closings]='\0'; //nach allclose kopieren
 strcpy(math_closings, suche+1);
 while (strlen(allclose)>0) {
       suche = strchr(allclose,'>');
       strncpy(nextclose,allclose,suche-allclose+1); nextclose[suche-allclose+1]='\0';
       strcpy(allclose, suche+1);
       if (strcmp(nextclose,">")==0) strcpy(nextclose,"");				//nichts zu beenden
       if (strcmp(nextclose,"R>")==0) {strcpy(nextclose,""); math_italics=1;}		//Roman beenden
       if (strcmp(nextclose,"O>")==0) {strcpy(nextclose,"&nbsp;"); math_italics=1;}	//Roman beenden + &nbsp;
       if (strcmp(nextclose,"}>")==0) strcpy(nextclose,"<tt>}</tt>");			//nicht unterstützter Befehl, noch eine Klammer schließen
       if (strcmp(nextclose,"F>")==0) {						//Zähler beendet
           strcpy(nextclose,"<tt>}{</tt>");
           math_addclose("}>");
       }
       strcat(close,nextclose);
 }
}

int math_command(char * command, char * aus)
//Wandelt ein Kommando in HTML um
//Rückgabe:  1: nach diesem Zeichen HTML-Tag schließen (z. B. \infty)
//          -1: es wurde ein neues HTML-Tag geöffnet (z. B. \mathrm)
{
 if ((strcmp(command,"\\text")==0)||(strcmp(command,"\\mathrm")==0)) {	//\text oder \mathrm -> ab hier in Roman
    math_italics=0;
    math_addclose("R>");		//schließendes Pseudotag für Ende Roman
    strcpy(aus,"");
    return -1;
 }
 if ((strcmp(command,"\\mathbf")==0)||(strcmp(command,"\\boldsymbol")==0)) {	//\mathbf oder \boldsymbol-> ab hier fett
    math_addclose("</b>");				//schließendes Tag für Ende Fett
    strcpy(aus,"<b>");
    return -1;
 }
 if (strcmp(command,"\\operatorname")==0) {	//\operatorname -> ab hier in Roman, mit &nbsp; abschließen
    math_italics=0;
    math_addclose("O>");		//schließendes Pseudotag für Ende Roman + &nbsp;
    strcpy(aus,"");
    return -1;
 }
 if (strcmp(command,"\\mathit")==0) {	//\mathit -> ab hier kursiv
    math_addclose("</i>");				//schließendes Tag für Ende Kursiv
    strcpy(aus,"<i>");
    return -1;
 }
 if (strcmp(command,"\\underline")==0) {	//\underline -> ab hier unterstreichen
    math_addclose("</u>");				//schließendes Tag für Ende Unterstreichen
    strcpy(aus,"<u>");
    return -1;
 }
 if ((strcmp(command,"\\mathfrak")==0)||(strcmp(command,"\\overline")==0)||(strcmp(command,"\\mathsf")==0)||(strcmp(command,"\\mathbb")==0)||(strcmp(command,"\\mathcal")==0)||(strcmp(command,"\\begin")==0)||(strcmp(command,"\\end")) {	//\mathfrak etc. nicht unterstützt
    math_addclose("}>");				//schließendes Pseudo-Tag für Ende
    strcpy(aus,"<tt>"); strcat(aus,command); strcat(aus,"{</tt>");
    return -1;
 } 
 //Hebräisch
 if (strcmp(command,"\\aleph")==0) {strcpy(aus,"&alefsym;"); return 1;}
 /*if (strcmp(command,"\\beth")==0) {strcpy(aus,"&#1489;"); return 1;}
 if (strcmp(command,"\\gimel")==0) {strcpy(aus,"&#1490;"); return 1;}
 if (strcmp(command,"\\daleth")==0) {strcpy(aus,"&#1491;"); return 1;}*/
 //Griechisch, nein nicht kursiv
 if (strcmp(command,"\\alpha")==0) {strcpy(aus,"&alpha;"); return 1;}
 if (strcmp(command,"\\beta")==0) {strcpy(aus,"&beta;"); return 1;}
 if (strcmp(command,"\\gamma")==0) {strcpy(aus,"&gamma;"); return 1;}
 if (strcmp(command,"\\delta")==0) {strcpy(aus,"&delta;"); return 1;}
 if (strcmp(command,"\\epsilon")==0) {strcpy(aus,"&epsilon;"); return 1;}
 if (strcmp(command,"\\varepsilon")==0) {strcpy(aus,"&epsilon;"); return 1;}
 if (strcmp(command,"\\zeta")==0) {strcpy(aus,"&zeta;"); return 1;}
 if (strcmp(command,"\\eta")==0) {strcpy(aus,"&eta;"); return 1;}
 if (strcmp(command,"\\theta")==0) {strcpy(aus,"&theta;"); return 1;}
 if (strcmp(command,"\\vartheta")==0) {strcpy(aus,"&thetasym;"); return 1;}
 if (strcmp(command,"\\iota")==0) {strcpy(aus,"&iota;"); return 1;}
 if (strcmp(command,"\\kappa")==0) {strcpy(aus,"&kappa;"); return 1;}
 if (strcmp(command,"\\varkappa")==0) {strcpy(aus,"&kappa;"); return 1;}
 if (strcmp(command,"\\lambda")==0) {strcpy(aus,"&lambda;"); return 1;}
 if (strcmp(command,"\\mu")==0) {strcpy(aus,"&mu;"); return 1;}
 if (strcmp(command,"\\nu")==0) {strcpy(aus,"&nu;"); return 1;}
 if (strcmp(command,"\\xi")==0) {strcpy(aus,"&xi;"); return 1;}
 if (strcmp(command,"\\omicron")==0) {strcpy(aus,"&omicron;"); return 1;}
 if (strcmp(command,"\\pi")==0) {strcpy(aus,"&pi;"); return 1;}
 if (strcmp(command,"\\varpi")==0) {strcpy(aus,"&piv;"); return 1;}
 if (strcmp(command,"\\rho")==0) {strcpy(aus,"&rho;"); return 1;}
 if (strcmp(command,"\\varrho")==0) {strcpy(aus,"&rho;"); return 1;}
 if (strcmp(command,"\\sigma")==0) {strcpy(aus,"&sigma;"); return 1;}
 if (strcmp(command,"\\varsigma")==0) {strcpy(aus,"&sigmaf;"); return 1;}
 if (strcmp(command,"\\tau")==0) {strcpy(aus,"&tau;"); return 1;}
 if (strcmp(command,"\\upsilon")==0) {strcpy(aus,"&upsilon;"); return 1;}
 if (strcmp(command,"\\phi")==0) {strcpy(aus,"&phi;"); return 1;}
 if (strcmp(command,"\\varphi")==0) {strcpy(aus,"&phi;"); return 1;}
 if (strcmp(command,"\\chi")==0) {strcpy(aus,"&chi;"); return 1;}
 if (strcmp(command,"\\psi")==0) {strcpy(aus,"&psi;"); return 1;}
 if (strcmp(command,"\\omega")==0) {strcpy(aus,"&omega;"); return 1;}
 if (strcmp(command,"\\Alpha")==0) {strcpy(aus,"&Alpha;"); return 1;}
 if (strcmp(command,"\\Beta")==0) {strcpy(aus,"&Beta;"); return 1;}
 if (strcmp(command,"\\Gamma")==0) {strcpy(aus,"&Gamma;"); return 1;}
 if (strcmp(command,"\\Delta")==0) {strcpy(aus,"&Delta;"); return 1;}
 if (strcmp(command,"\\Epsilon")==0) {strcpy(aus,"&Epsilon;"); return 1;}
 if (strcmp(command,"\\Zeta")==0) {strcpy(aus,"&Zeta;"); return 1;}
 if (strcmp(command,"\\Eta")==0) {strcpy(aus,"&Eta;"); return 1;}
 if (strcmp(command,"\\Theta")==0) {strcpy(aus,"&Theta;"); return 1;}
 if (strcmp(command,"\\Iota")==0) {strcpy(aus,"&Iota;"); return 1;}
 if (strcmp(command,"\\Kappa")==0) {strcpy(aus,"&Kappa;"); return 1;}
 if (strcmp(command,"\\Lambda")==0) {strcpy(aus,"&Lambda;"); return 1;}
 if (strcmp(command,"\\Mu")==0) {strcpy(aus,"&Mu;"); return 1;}
 if (strcmp(command,"\\Nu")==0) {strcpy(aus,"&Nu;"); return 1;}
 if (strcmp(command,"\\Xi")==0) {strcpy(aus,"&Xi;"); return 1;}
 if (strcmp(command,"\\Omicron")==0) {strcpy(aus,"&Omicron;"); return 1;}
 if (strcmp(command,"\\Pi")==0) {strcpy(aus,"&Pi;"); return 1;}
 if (strcmp(command,"\\Rho")==0) {strcpy(aus,"&Rho;"); return 1;}
 if (strcmp(command,"\\Sigma")==0) {strcpy(aus,"&Sigma;"); return 1;}
 if (strcmp(command,"\\Tau")==0) {strcpy(aus,"&Tau;"); return 1;}
 if (strcmp(command,"\\Upsilon")==0) {strcpy(aus,"&Upsilon;"); return 1;}
 if (strcmp(command,"\\Phi")==0) {strcpy(aus,"&Phi;"); return 1;}
 if (strcmp(command,"\\Chi")==0) {strcpy(aus,"&Chi;"); return 1;}
 if (strcmp(command,"\\Psi")==0) {strcpy(aus,"&Psi;"); return 1;}
 if (strcmp(command,"\\Omega")==0) {strcpy(aus,"&Omega;"); return 1;}
//mathematische Sonderzeichen

 if (strcmp(command,"\\\\")==0) {strcpy(aus,"<br />"); return 1;}
 if (strcmp(command,"\\,")==0) {strcpy(aus,"&nbsp;"); return 1;}
 if (strcmp(command,"\\|")==0) {strcpy(aus,"||"); return 1;}
 if (strcmp(command,"\\{")==0) {strcpy(aus,"{"); return 1;}
 if (strcmp(command,"\\}")==0) {strcpy(aus,"}"); return 1;}
 if (strcmp(command,"\\#")==0) {strcpy(aus,"#"); return 1;}
 if (strcmp(command,"\\angle")==0) {strcpy(aus,"&ang;"); return 1;}
 if (strcmp(command,"\\asymp")==0) {strcpy(aus,"&asymp;"); return 1;}
 if (strcmp(command,"\\backslash")==0) {strcpy(aus,"\\"); return 1;}
 if (strcmp(command,"\\bot")==0) {strcpy(aus,"&perp;"); return 1;}
 if (strcmp(command,"\\cap")==0) {strcpy(aus,"&cap;"); return 1;}
 if (strcmp(command,"\\cdot")==0) {strcpy(aus,"&middot;"); return 1;}
 if (strcmp(command,"\\circ")==0) {strcpy(aus,"&Omega;"); return 1;}
 if (strcmp(command,"\\cong")==0) {strcpy(aus,"&congruent;"); return 1;}
 if (strcmp(command,"\\cup")==0) {strcpy(aus,"&cup;"); return 1;}
 if (strcmp(command,"\\dagger")==0) {strcpy(aus,"&dagger;"); return 1;}
 if (strcmp(command,"\\ddagger")==0) {strcpy(aus,"&Dagger;"); return 1;}
 if (strcmp(command,"\\div")==0) {strcpy(aus,"&divide;"); return 1;}
 if (strcmp(command,"\\downarrow")==0) {strcpy(aus,"&darr;"); return 1;}
 if (strcmp(command,"\\Downarrow")==0) {strcpy(aus,"&dArr;"); return 1;}
 if (strcmp(command,"\\emptyset")==0) {strcpy(aus,"&empty;"); return 1;}
 if (strcmp(command,"\\equiv")==0) {strcpy(aus,"&equiv;"); return 1;}
 if (strcmp(command,"\\exist")==0) {strcpy(aus,"&exist;"); return 1;}
 if (strcmp(command,"\\forall")==0) {strcpy(aus,"&forall;"); return 1;}
 if (strcmp(command,"\\ge")==0) {strcpy(aus,"&ge;"); return 1;}
 if (strcmp(command,"\\geq")==0) {strcpy(aus,"&ge;"); return 1;}
 if (strcmp(command,"\\Im")==0) {strcpy(aus,"&image;"); return 1;}
 if (strcmp(command,"\\in")==0) {strcpy(aus,"&isin;"); return 1;}
 if (strcmp(command,"\\infty")==0) {strcpy(aus,"&infin;"); return 1;}
 if (strcmp(command,"\\int")==0) {strcpy(aus,"&int;"); return 1;}
 if (strcmp(command,"\\land")==0) {strcpy(aus,"&and;"); return 1;}
 if (strcmp(command,"\\lbrace")==0) {strcpy(aus,"{"); return 1;}
 if (strcmp(command,"\\lbrack")==0) {strcpy(aus,"["); return 1;}
 if (strcmp(command,"\\lceil")==0) {strcpy(aus,"&lceil;"); return 1;}
 if (strcmp(command,"\\ldots")==0) {strcpy(aus,"&hellip;"); return 1;}
 if (strcmp(command,"\\le")==0) {strcpy(aus,"&le;"); return 1;}
 if (strcmp(command,"\\leftarrow")==0) {strcpy(aus,"&larr;"); return 1;}
 if (strcmp(command,"\\Leftarrow")==0) {strcpy(aus,"&lArr;"); return 1;}
 if (strcmp(command,"\\leftrightarrow")==0) {strcpy(aus,"&harr;"); return 1;}
 if (strcmp(command,"\\Leftrightarrow")==0) {strcpy(aus,"&hArr;"); return 1;}
 if (strcmp(command,"\\leq")==0) {strcpy(aus,"&le;"); return 1;}
 if (strcmp(command,"\\lfloor")==0) {strcpy(aus,"&lfloor;"); return 1;}
 if (strcmp(command,"\\lor")==0) {strcpy(aus,"&or;"); return 1;}
 if (strcmp(command,"\\mid")==0) {strcpy(aus,"|"); return 1;}
 if (strcmp(command,"\\nabla")==0) {strcpy(aus,"&nabla;"); return 1;}
 if (strcmp(command,"\\ne")==0) {strcpy(aus,"&ne;"); return 1;}
 if (strcmp(command,"\\neg")==0) {strcpy(aus,"&not;"); return 1;}
 if (strcmp(command,"\\neq")==0) {strcpy(aus,"&ne;"); return 1;}
 if (strcmp(command,"\\ni")==0) {strcpy(aus,"&ni;"); return 1;}
 if (strcmp(command,"\\notin")==0) {strcpy(aus,"&notin;"); return 1;}
 if (strcmp(command,"\\oplus")==0) {strcpy(aus,"&oplus;"); return 1;}
 if (strcmp(command,"\\otimes")==0) {strcpy(aus,"&otimes;"); return 1;}
 if (strcmp(command,"\\parallel")==0) {strcpy(aus,"||"); return 1;}
 if (strcmp(command,"\\partial")==0) {strcpy(aus,"&part;"); return 1;}
 if (strcmp(command,"\\pm")==0) {strcpy(aus,"&plusmn;"); return 1;}
 if (strcmp(command,"\\prod")==0) {strcpy(aus,"&prod;"); return 1;}
 if (strcmp(command,"\\propto")==0) {strcpy(aus,"&prop;"); return 1;}
 if (strcmp(command,"\\rbrace")==0) {strcpy(aus,"}"); return 1;}
 if (strcmp(command,"\\rbrack")==0) {strcpy(aus,"]"); return 1;}
 if (strcmp(command,"\\rceil")==0) {strcpy(aus,"&rceil;"); return 1;}
 if (strcmp(command,"\\Re")==0) {strcpy(aus,"&real;"); return 1;}
 if (strcmp(command,"\\rfloor")==0) {strcpy(aus,"&rfloor;"); return 1;}
 if (strcmp(command,"\\rightarrow")==0) {strcpy(aus,"&rarr;"); return 1;}
 if (strcmp(command,"\\Rightarrow")==0) {strcpy(aus,"&rArr;"); return 1;}
 if (strcmp(command,"\\setminus")==0) {strcpy(aus,"\\"); return 1;}
 if (strcmp(command,"\\setminus")==0) {strcpy(aus,"\\"); return 1;}
 if (strcmp(command,"\\sim")==0) {strcpy(aus,"~"); return 1;}
 if (strcmp(command,"\\subset")==0) {strcpy(aus,"&sub;"); return 1;}
 if (strcmp(command,"\\subseteqq")==0) {strcpy(aus,"&sube;"); return 1;}
 if (strcmp(command,"\\sum")==0) {strcpy(aus,"&sum;"); return 1;}
 if (strcmp(command,"\\supset")==0) {strcpy(aus,"&sup;"); return 1;}
 if (strcmp(command,"\\supseteqq")==0) {strcpy(aus,"&supe;"); return 1;}
 if (strcmp(command,"\\times")==0) {strcpy(aus,"&times;"); return 1;}
 if (strcmp(command,"\\to")==0) {strcpy(aus,"&rarr;"); return 1;}
 if (strcmp(command,"\\uparrow")==0) {strcpy(aus,"&uarr;"); return 1;}
 if (strcmp(command,"\\Uparrow")==0) {strcpy(aus,"&uArr;"); return 1;}
 if (strcmp(command,"\\varnothing")==0) {strcpy(aus,"&empty;"); return 1;}
 if (strcmp(command,"\\vee")==0) {strcpy(aus,"&or;"); return 1;}
 if (strcmp(command,"\\wedge")==0) {strcpy(aus,"&and;"); return 1;}
 if (strcmp(command,"\\wp")==0) {strcpy(aus,"&weierp;"); return 1;}

//Funktionen
 if ((strcmp(command,"\\sin")==0)||(strcmp(command,"\\cos")==0)||(strcmp(command,"\\tan")==0)||(strcmp(command,"\\cot")==0)||(strcmp(command,"\\sec")==0)||(strcmp(command,"\\csc")==0)||(strcmp(command,"\\arcsin")==0)||(strcmp(command,"\\arccos")==0)||(strcmp(command,"\\arctan")==0)||(strcmp(command,"\\arccot")==0)||(strcmp(command,"\\arcsec")==0)||(strcmp(command,"\\arccsc")==0)||(strcmp(command,"\\sinh")==0)||(strcmp(command,"\\cosh")==0)||(strcmp(command,"\\tanh")==0)||(strcmp(command,"\\coth")==0)||(strcmp(command,"\\arg")==0)||(strcmp(command,"\\det")==0)||(strcmp(command,"\\deg")==0)||(strcmp(command,"\\dim")==0)||(strcmp(command,"\\exp")==0)||(strcmp(command,"\\lg")==0)||(strcmp(command,"\\ln")==0)||(strcmp(command,"\\log")==0)||(strcmp(command,"\\max")==0)||(strcmp(command,"\\min")==0)||(strcmp(command,"\\hom")==0)||(strcmp(command,"\\inf")==0)||(strcmp(command,"\\ker")==0)||(strcmp(command,"\\lim")==0)||(strcmp(command,"\\liminf")==0)||(strcmp(command,"\\limsup")==0)||(strcmp(command,"\\Pr")==0)||(strcmp(command,"\\sup")==0)||(strcmp(command,"\\sgn")==0)||(strcmp(command,"\\gcd")==0)||(strcmp(command,"\\lcm")==0))
 { strcpy(aus,command+1); strcat(aus,"&nbsp;"); return 1; }
 if (strcmp(command,"\\mod")==0) {strcpy(aus,"&nbsp;mod "); return 1;}
 if (strcmp(command,"\\bmod")==0) {strcpy(aus,"mod"); return 1;}

 if (strcmp(command,"\\frac")==0) {
    strcpy(aus,"<tt>"); strcat(aus,command); strcat(aus,"{</tt>");
    math_addclose("F>");				//schließendes Pseudo-Tag für Ende \frac
    return -1; }

 //Größenanpassung von Klammern gibt es keine
 if ((strcmp(command,"\\left")==0)||(strcmp(command,"\\right")==0))
    {strcpy(aus,""); return 0;}

 strcpy(aus,"<tt>");
 strcat(aus,command);
 strcat(aus,"</tt> ");
 return 1;
}

void TeX(char * ein, char * aus)
{
 char naechster [128];
 char * suche;
 char html [128];
 char zeichen;
 int close;		//soll nach dem Schritt ein HTML-Tag geschlossen werden?
 strcpy(math_closings,""); strcpy(aus,""); math_toclose=0; math_braceclose=0; math_italics=1;
 while (strlen(ein)>0) {
       close=0;
       if (math_getnext(ein,naechster)==1) {	//ein Befehl
          close=math_command(naechster, html);	//in HTML umwandeln
          strcat(aus,html);			//und anhängen
          if (close==-1) {close=0;}//HTML-Tag geöffnet
       } else {
          zeichen=naechster[0];
          switch (zeichen) {
          case '{':
                  if (math_braceclose+1!=math_toclose) {	//Klammer hier überflüssig
                  math_addclose(">");				//Dummy voranstellen
                  }
                  math_braceclose++; break;
         case '}':
                 math_braceclose--;
                 close=1;				//schließen
                 break;
         case '^':
                 strcat(aus,"<sup>");			//Beginn Hochstellung
                 math_addclose("</sup>");		//schließendes Tag für Hochstellung
                 break;
         case '_':
                 strcat(aus,"<sub>");			//Beginn Tieftellung
                 math_addclose("</sub>");		//schließendes Tag für Tiefstellung
                 break;
         case ' ': break;				//Leerzeichen ignorieren
         case '<':
                 strcat(aus,"&lt;"); close=1;		//Kleiner, Größer und Ampersand maskieren
                 break;
         case '>':
                 strcat(aus,"&gt;"); close=1;
                 break;
         case '&':
                 strcat(aus,"&amp;"); close=1;
                 break;
         case '-':					//Minus
                 strcat(aus,"&minus;"); close=1;
                 break;
         case '\'':					//Ableitung
                 strcat(aus,"&prime;"); close=1;
                 break;
         case 'a': case 'b': case 'c': case 'd': case 'e': case 'f': case 'g': case 'h':
         case 'i': case 'j': case 'k': case 'l': case 'm': case 'n': case 'o': case 'p':
         case 'q': case 'r': case 's': case 't': case 'u': case 'v': case 'w': case 'x':
         case 'y': case 'z': case 'A': case 'B': case 'C': case 'D': case 'E': case 'F':
         case 'G': case 'H': case 'I': case 'J': case 'K': case 'L': case 'M': case 'N':
         case 'O': case 'P': case 'Q': case 'R': case 'S': case 'T': case 'U': case 'V':
         case 'W': case 'X': case 'Y': case 'Z':	//Buchstaben evt. kursiv
                if (math_italics) strcat(aus,"<i>");
                strcat(aus,naechster);
                if (math_italics) strcat(aus,"</i>");
                close=1;
                break;
         default:
                strcat(aus,naechster);			//Zeichen ausgeben
                close=1;
          }
       };
       if ((close==1) && (math_braceclose!=math_toclose)) {	//es soll geschlossen werden und es sind auch keine geschweiften Klammern übrig
          math_getnextclose(html);		//schließendes Tag abholen
          strcat(aus,html);			//und anhängen
       }
 }
 //</i><i> löschen
 while ((suche=strstr(aus,"</i><i>"))!=NULL) {
       suche[0]='\0';
       strcat(aus,suche+7);
 }
}

int main (void)
{
 char eingabe[1024];	//Nimmt die Eingabe entgegen
 char ausgabe[1024];	//Nimmt die Ausgabe entgegen
 printf("TeX (ohne) <math>...</math>: ");
 fgets(eingabe,1024,stdin);	//einlesen
 TeX(eingabe, ausgabe);	//TeX -> HTML
 printf("%s",ausgabe);	//ausgeben
 return 0;
} 
