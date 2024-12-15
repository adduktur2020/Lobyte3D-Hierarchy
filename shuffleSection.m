function shuffledSection = shuffleSection(section, totalSwaps)
% function to shuffle the facies succession to ensure a random configuration

    % Make a copy of the original data in new array that will be used to store the shuffled section
    shuffledSection = section;
    n = uint16(max(size(shuffledSection)));
    
    for j =1: totalSwaps
        
        % Select two unit numbers randomly to be swapped
        unit1 = uint16((rand * (n-1)) + 1);
        unit2 = uint16((rand * (n-1)) + 1);

        %Swap the thicknesses
        temp = shuffledSection(unit1);
        shuffledSection(unit1) = shuffledSection(unit2);
        shuffledSection(unit2) = temp;
    end
end