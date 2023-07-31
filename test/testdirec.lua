require "wordcloud"


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

test = wc_list_to_table("(LaTeX,8);(test,6);(coucou,2)")

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
