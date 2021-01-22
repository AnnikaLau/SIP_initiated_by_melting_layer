
function runs = get_runs()

n_runs = 9;
fileID =fopen('C:\melting_layer\Data\HoloGondel\190222_runs_gondola_up.txt','r');
formatSpec ='%d%s%d%s%2d\n';
sizeA = [5,n_runs*2];
A = fscanf(fileID,formatSpec,sizeA);
fclose(fileID)
year = 2019;
month = 2;
day = 22;
h = A(1,:);
m = A(3,:);
s = A(5,:);

runs = zeros(n_runs,2);
for i=1:n_runs
    runs(i,1) = datenum(year,month,day,h((i-1)*2+1),m((i-1)*2+1),s((i-1)*2+1));
    runs(i,2) = datenum(year,month,day,h((i-1)*2+2),m((i-1)*2+2),s((i-1)*2+2));
end

end