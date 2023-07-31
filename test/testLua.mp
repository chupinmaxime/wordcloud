input wordcloud
        beginfig(0);
        string words[];
        numeric weights[];
    words[1]:="LaTeX";weights[1]:=0.5;draw_wordcloud(words,weights,0,0);endfig;end.