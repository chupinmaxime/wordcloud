%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                        wordcloud                           %%
%%                    drawing wordclouds                      %%
%%                   with METAPOST and Lua                    %%
%%                chupin@ceremade.dauphine.fr                 %%
%%                Version 0.2 (septembre    2023)             %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This work may be distributed and/or modified under the conditions of
% the LaTeX Project Public License, either version 1.3c of this license
% or (at your option) any later version.  The latest version of this
% license is in http://www.latex-project.org/lppl.txt
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if not known mplib: input latexmp ; show"wordcloud Infos: latexmp loaded";fi;
input colorbrewer-rgb


% function to get all the path of letters (too slow)
vardef build_pathpicture(expr pict)=
    save tex_pct,glp_pct,glp_idx,glp_num,pth_num,glp_pth,fnt_str, txt_str, sub_str,txt_wd;
    % text material and glyphs contours
    picture tex_pct, glp_pct;
    numeric glp_num, pth_num[];
    path glp_pth[][];
    % tex_pct       btex .. etex material
    % glp_num       number of glyphs within tex_pct
    % pth_num[i]    number of paths defining the rank i (0 .. glp_num-1) glyph
    % glp_pth[i][j] rank j (0 .. pth_num[i]-1) path of the rank i glyph
    % glp_pct       glyphs picture
    
    tex_pct:=pict;
    
    glp_pct:=nullpicture;
    string fnt_str, txt_str, sub_str;
    numeric txt_wd;
    glp_num:=0;
    for tkn within pict:
      %show tkn;
      if textual tkn:
        %show "textual";
        fnt_str:=fontpart tkn;
        txt_str:=textpart tkn;
        txt_wd:=0;
        for glp_idx=0 upto (length txt_str-1):
          sub_str:=substring (glp_idx, glp_idx+1) of txt_str;
          for sub_tkn within glyph ASCII sub_str of fnt_str
              scaled (fontsize fnt_str/1000)
              xscaled xxpart tkn
              yscaled yypart tkn
              shifted (txt_wd+xpart tkn, ypart tkn):
            addto glp_pct doublepath (pathpart sub_tkn);
          endfor
          txt_wd:=txt_wd+
            (xxpart tkn)*xpart urcorner (sub_str infont fnt_str);
        endfor
      fi
    endfor
    glp_pct
enddef;


% path intersection (trop gourmant en temps, too slow...)
vardef word_intersection(expr tic, tac)=
    save _p, _w, _v,_output;
    boolean _output;
    _output:=false;
    path _p,_w,_v;
    for _p within tic:
      _w := pathpart _p;
      for _q within tac:
        _v := pathpart _q;
        if((_w intersectiontimes _v)<>(-1,-1)): % intersection
          _output:=true;
        fi
      endfor
    endfor
    _output    
enddef;

% global variable 
_wordcloud_box_margin:=0.3pt;

% setting the box margin
def set_box_margin(expr s)=
  _wordcloud_box_margin:=s;
enddef;

% extrenal box intersection (horizontal or vertical)
vardef extbb_intersection(expr tic, tac)=
    save xmax_, xmin_, ymax_, ymin_, xmax__, xmin__, ymax__, ymin__, _output;
    boolean _output;
    _output:=false;
    %show _p;
    xmin_:= (xpart llcorner tic) -_wordcloud_box_margin;  
    ymin_ := (ypart llcorner tic)-_wordcloud_box_margin; 
    xmax_:= (xpart urcorner tic)+_wordcloud_box_margin;
    ymax_ := (ypart urcorner tic)+_wordcloud_box_margin;
    xmin__:= (xpart llcorner tac)-_wordcloud_box_margin;  
    ymin__ := (ypart llcorner tac)-_wordcloud_box_margin; 
    xmax__:= (xpart urcorner tac)+_wordcloud_box_margin;
    ymax__ := (ypart urcorner tac)+_wordcloud_box_margin;
    if ((xmin_<= xmax__) and (xmax_ >= xmin__) and  (ymin_<= ymax__) and (ymax_ >= ymin__)):
      _output:=true;
    fi
    _output   
enddef;

% subbb_entersection of words (from textext)
%%%!!!!!! not working !!!!!!!!!
vardef bb_intersection(expr tic, tac)=
    save xmax_, xmin_, ymax_, ymin_, xmax__, xmin__, ymax__, ymin__,
    _output;
    save _p, _w, _v,_output,_q;
    boolean _output;
    _output:=false;
    path _p,_w,_v;
    i:=0;
    for _v within tic:
      for _p within _v:
      i:=i+1;
      %show "i"&decimal(i);
      xmin_:= (xpart llcorner _p)-_wordcloud_box_margin;  
      ymin_ := (ypart llcorner _p)-_wordcloud_box_margin; 
      xmax_:= (xpart urcorner _p)+_wordcloud_box_margin;
      ymax_ := (ypart urcorner _p)+_wordcloud_box_margin;
      j:=0;
      for _w within tac:
        for _q within _w:
        j:=j+1;
        %show "j"&decimal(j);
        xmin__:= (xpart llcorner _q)-_wordcloud_box_margin;  
        ymin__ := (ypart llcorner _q)-_wordcloud_box_margin; 
        xmax__:= (xpart urcorner _q)+_wordcloud_box_margin;
        ymax__ := (ypart urcorner _q)+_wordcloud_box_margin;
        if ((xmin_<= xmax__) and (xmax_ >= xmin__) and  (ymin_<= ymax__) and (ymax_ >= ymin__)):
          _output:=true;
        fi
        exitif(_output);
        endfor
      endfor
      exitif(_output);
    endfor
    endfor
    _output   
enddef;


% build the spiral to put words
path _wordcloud_spiral;

_wordcloud_spiral:=(0,0);

_wordcloud_N:= 10*360;
_tours:=20;
_scale:=0.3;
for j:=1 upto _tours:
  _rapj:=j/_tours;
  for i:=1 step 10 until 360:
    _rapi:=((i)+(j)*360)/360;
    %show (_rapj*_rapi);
    %show (6*_rapj*_rapi)*(cosd(i)*1cm,sind(i)*1cm);
    _wordcloud_spiral:=_wordcloud_spiral--((_scale*_rapi)*(cosd(i)*1cm,sind(i)*1cm));
  endfor;
endfor

picture _wordcloud_words[], _wordcloud_pathwords[];
path _wordcloud_words_oriented_bb[];
numeric _wordcloud_weights[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%   FONCTIONS USUELLES   %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% from repere.mp Olivier Péault

pi:=3.141592654;
e:=2.718281828;

vardef sin(expr x) = sind(180*x/pi) enddef;

vardef cos(expr x) = cosd(180*x/pi) enddef;

vardef tan(expr x) = sin(x)/cos(x) enddef;

vardef exp(expr x) = mexp(x*256) enddef;

vardef ln(expr x) = mlog(x)/256 enddef;

vardef ch(expr x)=(exp(x)+exp(-x))/2 enddef;

vardef sh(expr x)=(exp(x)-exp(-x))/2 enddef;

vardef Arctan(expr x)= pi*angle(1,x)/180 enddef;
vardef Arctand(expr x)= angle(1,x) enddef;

vardef Arcsin(expr x)= Arctan(x/sqrt(1-x**2)) enddef;
vardef Arcsind(expr x)= Arctand(x/sqrt(1-x**2)) enddef;

vardef Arccos(expr x)= pi/2-Arcsin(x) enddef;
vardef Arccosd(expr x)=  Arctand((sqrt(1-x**2))/x)enddef;

% general scaling
_wordcloud_gen_scale:=1;

def set_wordcloud_scale(expr s)=
  _wordcloud_gen_scale:=s;
enddef;

% fonction d'agrandissement en fonction du poids du mot
vardef _wordcloud_scale_fct(expr e,_max,_min)=
  save _t,_N,_a,_b;
  _a*_min+_b=0.7;
  _a*_max+_b=2.5;
  _t:=_a*e+_b;
  _t:=ln(_t)-ln(0.7)+0.295;
  _wordcloud_gen_scale*(1.1*_t)
enddef;

% fabrication des mots avec la taille requise
vardef _build_tabs(suffix _words, _weights)(expr _N)=
  save _tmp_pict,_width,_height;
  picture _tmp_pict; 
  for i=1 upto _N:
    _tmp_pict:=textext(_words[i]) scaled (_wordcloud_scale_fct(_weights[i],_weights[1],_weights[_N]));
    _width:=abs(ulcorner _tmp_pict - urcorner _tmp_pict);
    _height:=abs(ulcorner _tmp_pict - llcorner _tmp_pict);
    _wordcloud_words[i]:= _tmp_pict shifted (-0.5_width,-0.5_height);
    _wordcloud_weights[i]:=_weights[i];
    _bbox_old:=bboxmargin;
    bboxmargin:=_wordcloud_box_margin;
    _wordcloud_words_oriented_bb[i]:= bbox _wordcloud_words[i];
    bboxmargin:=_bbox_old;
    _wordcloud_pathwords[i]:=build_pathpicture(_wordcloud_words[i]) ;
  endfor;
enddef;
% function to compute angle
def _wordcloud_rotation(expr a,b)=
% a: angle 
% b: 0 or 1
  if b=0:
    a
  else:
    if(a=0):
      90
    else:
      -a
    fi
  fi
enddef;

%%% colors
boolean _wordcloud_use_color;
_wordcloud_use_color:=false;

numeric wordcloud_colors_number;
color wordcloud_colors[];

% default colors
wordcloud_colors[1]:=Reds[3][3];
wordcloud_colors[2]:=Greens[3][3];
wordcloud_colors[3]:=Blues[3][3];
wordcloud_colors[4]:=Oranges[3][3];
wordcloud_colors[5]:=black;
wordcloud_colors_number:=5;

def wordcloud_use_color(expr b)=
  _wordcloud_use_color:= b;
enddef;
 
% main function to draw the picture 
vardef draw_wordcloud(suffix _words, _weights, rotation)(expr _N)=
  save _rotation_bool,_position,_ok_draw,_tmp_word,_random_pt,_position_pt,_pt;
  pair _random_pt,_position_pt,_pt;
  path _tmp_word;
  boolean _ok_draw;
  _position:=0;
  _build_tabs(_words,_weights,_N);
  for i=1 upto _N:
    %show i;
    _position:=0;
    if(i mod 2) = 0:
      _rotation_bool:=1;
    else:
      _rotation_bool:=0;
    fi
    if(i=1):
      draw _wordcloud_words[i] rotated (_wordcloud_rotation(rotation,_rotation_bool)) shifted (point _position
      of _wordcloud_spiral) if(_wordcloud_use_color): withcolor wordcloud_colors[i] fi ;
      _position_pt:=(0,0);
      _random_pt:=(0,0);
    else:
      _count:=0;
      
      forever:
        _position_pt:=point _position of _wordcloud_spiral;
        _random_pt:=(uniformdeviate(1)*0.01cm,uniformdeviate(1)*0.01cm);
        _pt:=_position_pt+_random_pt;
        _count:=_count+1;
        _ok_draw:= true;
        _tmp_word:=_wordcloud_words_oriented_bb[i] rotated (_wordcloud_rotation(rotation,_rotation_bool)) shifted (_position_pt + _random_pt);
        %_tmp_word:=_wordcloud_words[i] rotated (_rotation*90) shifted (point %_position
        %  of _wordcloud_spiral);
        for j=1 upto i-1:
          if(rectangles_intersection(_tmp_word,_wordcloud_words_oriented_bb[j])):
            %if(bb_intersection(_tmp_word,_wordcloud_words[j])):
              _ok_draw:= false;
            %fi
          fi
        endfor;
        if(_ok_draw): % if there is no intersections
          draw _wordcloud_words[i] rotated
          (_wordcloud_rotation(rotation,_rotation_bool)) shifted (_position_pt +
          _random_pt)  if(_wordcloud_use_color): withcolor wordcloud_colors[((i-1)
          mod wordcloud_colors_number)+1] fi;
        else: % else, we move along the spiral
          _position:=_position+1;
        fi
        exitif(_ok_draw);
        %exitif(_count>30);
      endfor;
    fi
    _wordcloud_words[i]:=_wordcloud_words[i] rotated (_wordcloud_rotation(rotation,_rotation_bool)) shifted
    (_position_pt + _random_pt); 
    _wordcloud_words_oriented_bb[i]:=_wordcloud_words_oriented_bb[i] rotated (_wordcloud_rotation(rotation,_rotation_bool)) shifted
    (_position_pt + _random_pt); 
    _wordcloud_pathwords[i]:=_wordcloud_pathwords[i] rotated (_wordcloud_rotation(rotation,_rotation_bool)) shifted
    (_position_pt + _random_pt);    
  endfor;
enddef;


vardef dotproduct(expr a,b)=
  save _output;
  _output := (xpart a)*(xpart b)+(ypart a)*(ypart b);
  _output
enddef;

vardef normvec(expr p)= 
  p/(sqrt((xpart p)**2+(ypart p)**2))
enddef;

vardef bb_projection(expr p,a)=
  % p : edge of a rectangle (pair)
  % a : axis of proj 
  dotproduct(p,a)
enddef;

% intersection of oriented rectangel
vardef rectangles_intersection(expr tic,tac)=
  % tic, tac, two rectangular path (closed)
  save x,y,a,b,normedge,edge,_min,_max,_dotprod,_output,_minEdge,_maxEdge;
  pair normedge,edge;
  boolean _output;
  _output:=false;
  numeric x[],y[],a[],b[];
  (x1,y1) = point 1 of tic;
  (x2,y2) = point 2 of tic;
  (x3,y3) = point 3 of tic;
  (x4,y4) = point 4 of tic;
  (a1,b1) = point 1 of tac;
  (a2,b2) = point 2 of tac;
  (a3,b3) = point 3 of tac;
  (a4,b4) = point 4 of tac;
  for i=1 upto 4:
    %show (x[i],y[i]);
  endfor;
   for i=1 upto 4:
    %show (a[i],b[i]);
  endfor;
  %draw (a1,b1)--(a2,b2)--(a3,b3)--(a4,b4);
  for i=1 upto 2: % on prend deux côtés perpendiculaire du rectangle 1
    %show "premier";
    %show i;
    edge:=(x[i+1],y[i+1])-(x[i],y[i]);
    %show edge;
    normedge:=normvec(edge);
    for j=1 upto 4: %pour chaque point de deuxième triangle on projette sur
    % l’axe du côté du rectangle 1 qu’on considère
      _dotprod:=dotproduct((x[j],y[j]),normedge);
      if(j=1):
        _minEdge:=_dotprod;
        _maxEdge:=_dotprod;
      fi
      if(_dotprod<_minEdge):
        _minEdge:=_dotprod;
      else:
        if(_dotprod>_maxEdge):
          _maxEdge:=_dotprod;
        fi
      fi
      %show _minEdge;
      %show _maxEdge;
    endfor;
    %show _minEdge;
    %show _maxEdge;
    
    for j=1 upto 4: %pour chaque point de deuxième triangle on projette sur
    % l’axe du côté du rectangle 1 qu’on considère
      _dotprod:=dotproduct((a[j],b[j]),normedge);
      if(j=1):
        _min:=_dotprod;
        _max:=_dotprod;
      fi
      if(_dotprod<_min):
        _min:=_dotprod;
      else:
        if(_dotprod>_max):
          _max:=_dotprod;
        fi
      fi
    endfor;
    %show _min;
    %show _max;
    if (_min>_maxEdge) or (_max<_minEdge):
        %show "OK";
        _output:=true;
    fi
  endfor; %the other way
  for i=1 upto 2: % on prend deux côtés perpendiculaire du rectangle 1
    %show "deuxième";
    %show i;
    edge:=(a[i+1],b[i+1])-(a[i],b[i]);
    %show edge;
    normedge:=normvec(edge);
    for j=1 upto 4: %pour chaque point de deuxième triangle on projette sur
    % l’axe du côté du rectangle 1 qu’on considère
      _dotprod:=dotproduct((a[j],b[j]),normedge);
      if(j=1):
        _minEdge:=_dotprod;
        _maxEdge:=_dotprod;
      fi
      if(_dotprod<_minEdge):
        _minEdge:=_dotprod;
      else:
        if(_dotprod>_maxEdge):
          _maxEdge:=_dotprod;
        fi
      fi
      %show _minEdge;
      %show _maxEdge;
    endfor;
    %show _minEdge;
    %show _maxEdge;

    for j=1 upto 4: %pour chaque point de deuxième triangle on projette sur
    % l’axe du côté du rectangle 1 qu’on considère
      _dotprod:=dotproduct((x[j],y[j]),normedge);
      if(j=1):
        _min:=_dotprod;
        _max:=_dotprod;
      fi
      if(_dotprod<_min):
        _min:=_dotprod;
      else:
        if(_dotprod>_max):
          _max:=_dotprod;
        fi
      fi
    endfor;
    if (_min>_maxEdge) or (_max<_minEdge):
      %show "OK";
      _output:=true;
    fi
  endfor;
  not _output
enddef;

