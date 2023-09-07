--[[
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
]]
function wc_file2string(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end

function wc_table_concat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function wc_ignor_fr()
    local output;
    output= {"et", "donc", "alors", "les", "ainsi", "des", "que", "qui", "sont", "par", "dans","est","pour","une","peut","avec","sans","Les","son","sur","ces","ses","tandis","quand"}
    return output
end

function wc_ignor_en()
    local output;
    output= {"and", "so", "the", "the", "hence", "some", "that", "are", "is", "have", "has","in","on","could","should","with","be","this","these","where","when","not","with","can",}
    return output
end

-- global variable for ignored words
wordcloud_ignor_words = {};
wc_table_concat(wordcloud_ignor_words,wc_ignor_fr())
wc_table_concat(wordcloud_ignor_words,wc_ignor_en())

-- function to add list of words to be ignored
function wc_add_ignored_words(tab)
    wc_table_concat(wordcloud_ignor_words,tab)    
end

-- function to build a tab from a string of the form
-- word1,word2,word3,etc.
function wc_string_to_tab(strWord)
    strWord=string.gsub(strWord, "%s+", "") -- space delete
    local tab
    tab = string.explode(strWord, ",")
    return tab
end

function wc_build_word_table(mystr)
    local loc_str = mystr;
    local ignor_chars = {";","’","'","\"","{","}","[","]","(",")","…",".","?","!","$","\\","#","<",">","«","»","+","*","-","/","=","%%", "€",":","~"}
    loc_str = loc_str:gsub('[%p%c]+',' ')
    for i=1,#ignor_chars do
        loc_str = loc_str:gsub('['..ignor_chars[i]..']+',' ')
    end
    for i=1,#wordcloud_ignor_words do
        loc_str = loc_str:gsub(' '..wordcloud_ignor_words[i]..' ',' ')
    end
    loc_str = loc_str:gsub(' LaTeX ',' \\LaTeX ')
    loc_str = loc_str:gsub(' TeX ',' \\TeX ')
    local t = {}
    for i in loc_str:gmatch("%S+") do  
        t[#t + 1] = i
    end 
    -- delete 2 size words
    local id_two={}
    for i=1,#t do
       if(string.len(t[i])<=2)  then
        table.insert(id_two,i) 
       end
    end 
    for i=#id_two,1,-1 do
        table.remove(t,id_two[i])
    end
    return t
end

function wc_build_table_weight(t)
  local weight = {}
  for _, v in ipairs(t) do
    weight[v] = (weight[v] or 0) + 1
  end
  return weight
end

function wc_table_to_tabular(table_weight)
    local total_occ = 0
    local tabular_weight = {}
    for k,v in pairs(table_weight) do 
        total_occ=total_occ+v
    end
    local i=0
    for k,v in pairs(table_weight) do
        i=i+1 
        tabular_weight[i] ={}
        tabular_weight[i][1]=k
        tabular_weight[i][2]=v/total_occ
    end
    table.sort(tabular_weight,function (k1, k2) return k1[2] > k2[2] end)
    return tabular_weight
end

function wc_build_mp_code(table_weight,maximum,rotation)
    -- optional arguments
    maximum = maximum or 50
    rotation = rotation or 0

    local total_occ = 0
    local tabular_weight = wc_table_to_tabular(table_weight)
    
    
    local str_mp=[[
        string words[];
        numeric weights[];
    ]]
    local i=0
    for i=1, #tabular_weight do
        str_mp=str_mp.."words["..i.."]:=\""..tabular_weight[i][1].."\";"
        str_mp=str_mp.."weights["..i.."]:="..tabular_weight[i][2]..";"
        if (i>=maximum) then
            break
        end
    end
    str_mp=str_mp.."draw_wordcloud(words,weights,"..rotation..","..math.min(maximum,#tabular_weight)..");"
    return str_mp
end

function wc_list_to_table(list)
    -- list of words and weights (word1,weight1);(word2,weight2); etc.
    local table_weight = {}
    local pair = string.explode(list, ";")
    local lgth=#pair
    for i=1,lgth do
        word,weight=string.match(pair[i],"%((.+),(.+)%)")
        table_weight[word]=weight
    end
    return table_weight
end

function wc_size_of_table(table)
    local lengthNum = 0

    for k, v in pairs(table) do -- for every key in the table with a corresponding non-nil value 
        lengthNum = lengthNum + 1
    end
    return lengthNum
end 


function wc_build_color_list(colors)
    -- list of LaTeX colors separated with colons
    local out = ""
    local pair = string.explode(colors:sub(1,-2), ";") -- sub(1,-2) to delete last ;
    local lgth=#pair
    for i=1,lgth do
        out=out.."wordcloud_colors["..i.."]:="..pair[i]..";";   
    end
    out=out.."wordcloud_colors_number:="..lgth..";"
    return out
end

-- build mp code for the wordcloud of a list given in LaTeX command
function wc_build_wordcloud(str,rotation,scale,margin,usecolor,colors)
    maximum = maximum or 50
    local table = wc_list_to_table(str)
    local lgth_table = wc_size_of_table(table)
    local output
    output= [[\begin{mplibcode}[wordcloud]
    input wordcloud
    beginfig(0);
    ]] 
    if(usecolor=="true") then
        output = output.."wordcloud_use_color(true);"    
        if(colors~="") then
            output=output..wc_build_color_list(colors)
        end
    end
    output = output.."set_wordcloud_scale("..scale..");"
    output = output.."set_box_margin("..margin..");"
    output = output..wc_build_mp_code(table,lgth_table,rotation)
    output = output.."endfig;\\end{mplibcode}"
    tex.sprint(output)
end


-- build mp code for the wordcloud of a file given in LaTeX command
function wc_build_wordcloud_file(file,number,rotation,scale,margin,usecolor,colors)
    local str = wc_file2string(file)

    local words = wc_build_word_table(str)

    local table_weight = wc_build_table_weight(words)
    local output
    output= [[\begin{mplibcode}[wordcloud]
    input wordcloud
    beginfig(0);
    ]] 
    if(usecolor=="true") then
        output = output.."wordcloud_use_color(true);"    
        if(colors~="") then
            output=output..wc_build_color_list(colors)
        end
    end
    output = output.."set_wordcloud_scale("..scale..");"
    output = output.."set_box_margin("..margin..");"
    output = output..wc_build_mp_code(table_weight,number,rotation)
    output = output.."endfig;\\end{mplibcode}"
    tex.sprint(output)
end
