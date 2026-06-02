
clc; clear; close all;
iris = load("iris.mat");

features = iris.data;
label = iris.label;

setosaIndex = label==1;
versicolorIndex = label==2;
virginicaIndex = label==3;

setosa = features(setosaIndex,:);
versicolor = features(versicolorIndex,:);
virginica = features(virginicaIndex,:);

characteristics = ["sepal length","sepal width",...
    "petal length","petal width"];

pairs = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4];

for i = 1:6
    x = pairs(i,1); 
    y = pairs(i,2);   
    subplot(2,3,i)
    plot([setosa(:,x) versicolor(:,x) virginica(:,x)],...
         [setosa(:,y) versicolor(:,y) virginica(:,y)],".")
    xlabel(characteristics(x))
    ylabel(characteristics(y))
end

options = pfcmOptions(...
    NumClusters=3,...
    Exponent=2.0, ...
    MaxNumIteration=100, ...
    MinImprovement=1e-6, a=1);

options.Verbose = false; 

[centers,U, obj_func] = pfcm(features, options);


for i = 1:6
    subplot(2,3,i)
    for j = 1:options.NumClusters
        x = pairs(i,1);
        y = pairs(i,2);
        text(centers(j,x),centers(j,y),int2str(j),...
            FontWeight="bold");
    end
end