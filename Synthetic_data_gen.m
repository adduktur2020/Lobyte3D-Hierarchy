% Set random seed for reproducibility
rng('default');

% Number of clusters and subclusters
num_clusters = 3;
num_subclusters = 4;

% Number of data points per subcluster
num_points_per_subcluster = 50;

% Initialize data matrix
data = [];

% Create data for each cluster and subcluster
for cluster = 1:num_clusters
    for subcluster = 1:num_subclusters
        % Generate random data with a common pattern within each subcluster
        x = randn(1, num_points_per_subcluster) * 0.5 + cluster * 5;
        y = randn(1, num_points_per_subcluster) * 0.5 + subcluster * 5;
        
        % Combine data points
        data = [data; [x', y']];
    end
end

% Perform hierarchical clustering
Z = linkage(data, 'ward', 'euclidean');  % Using Ward linkage and Euclidean distance

% Plot the dendrogram
tree = dendrogram(Z);
title('Dendrogram of Hierarchical Clustering');
xlabel('Data Points');
ylabel('Distance');


    linkage_heights = get(tree,'Ydata'); 
    h_array = cell2mat(linkage_heights);
    h_array = h_array(:,2);

     linkageDistances = h_array;
    linkageDistancesCumFreq = cumsum(linkageDistances);
    linkageDistancesCumRelativeFreq = linkageDistancesCumFreq ./ max(linkageDistancesCumFreq);

    

    figure
    plot(linkageDistances, linkageDistancesCumRelativeFreq, "+--", "LineWidth",2.0)
    xlabel("Linkage distance")
    ylabel("Cumulative relative frequency")
    grid on
