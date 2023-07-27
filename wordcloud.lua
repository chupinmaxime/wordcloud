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
    output= {"and", "so", "the", "the", "hence", "some", "that", "are", "is", "have", "has","in","on","could","should","with","be","this","these","where","when",}
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

function wc_build_table_weight(mystr)
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

function wc_build_weight(t)
  local weight = {}
  for _, v in ipairs(t) do
    weight[v] = (weight[v] or 0) + 1
  end
  return weight
end

function wc_build_mp_code(table_weight,maximum,rotation)
    -- optional arguments
    maximum = maximum or 50
    rotation = rotation or 0

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
    --for i=1,#tabular_weight do 
    --    print(tabular_weight[i][1],tabular_weight[i][2])
    --end
    
    local str_mp=[[input wordcloud
        beginfig(0);
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
    str_mp=str_mp.."draw_wordcloud(words,weights,"..rotation..","..math.min(maximum,#tabular_weight)..");endfig;"
    return str_mp
end

function wc_build_mp_code_list()

str = wc_file2string("texte.txt")
--table_w = str:gmatch("%S+")
--print(type(table_w))
--for w in table_w do
--    print(w)
--end

t = wc_build_table_weight(str)

test = wc_build_weight(t)
--for k,v in pairs(test) do
--    print(k,v)
--end

output = wc_build_mp_code(test,20,0)
--print(output)

file = io.open("testLua.mp", "w")
file:write(output.."end.")
file:close()

file = io.open("testLuaTeX.tex", "w")
LuaOutput = [[
    \documentclass{standalone}
    \usepackage{xcharter-otf}
    \usepackage{luamplib}
    
    \begin{document}
    \begin{mplibcode} 
]]..output..[[
\end{mplibcode}
\end{document} 
]]
file:write(LuaOutput)
file:close()
