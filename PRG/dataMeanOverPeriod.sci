function meanValues = dataMeanOverPeriod(Data,tBeg,tEnd)
    iTime = find (Data(:,1) >= tBeg & Data(:,1) <= tEnd)
    meanValues = mean(Data(iTime, 3))
endfunction
