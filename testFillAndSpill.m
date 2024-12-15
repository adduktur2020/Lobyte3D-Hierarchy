function testFillAndSpill

    topog = [0.2559    5.7828    6.3982; 0.2697    0.2461    5.2279; 0.2827    0.2502    1.1141;]
    x = 2; y = 2;
    
    nbrTopog = topog;
    nbrTopog(2,2) = 5000000;
    
    nbrTopog(2,2) = 5000000;
    minNbrTopog = min(min(nbrTopog))
    [lowY, lowX] = find(nbrTopog==minNbrTopog)
    topoBlockRelief = topog(lowY, lowX) - topog(y,x)

    
end