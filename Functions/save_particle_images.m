% cD_data = 'C:\melting_layer\Data\HoloGondel\ice_habits_cD';
% saving_folder = 'C:\hologondel_analysis\Plots\Particle_images';
% prop = 100; %percentage of images that will be saved

function save_particle_images(cD_data,saving_folder,prop)
load(cD_data)
map = gray;
%delete data in the afternoon and before 8
a = [];
for i = 1:length(temp1.prtclID)
    t = split(temp1.prtclID{i},'-');
    t = str2double(t{4});
    if t<10 && t>7% && temp1.class(i) ~= 'Out_of_focus'
        a = [a;i];
    end
end
temp1.prtclID = temp1.prtclID(a);
temp1.metricmat = temp1.metricmat(a,:);
temp1.prtclIm =temp1.prtclIm(a);
temp1.class = temp1.class(a);

for i = 1:length(temp1.prtclIm)
    h = abs(temp1.prtclIm{i});
    h = mat2gray(h);
    imagesc(h);
    colormap(map);
    axis image;
    axis tight off;
    frame = getframe(gca);
    framedata = frame.cdata;
    he = size(h,1);
    w = size(h,2);
    t = split(temp1.prtclID{i},'_');
    t = t{1};
    t = t(12:19);
    
    %Get random selection
    r = 100/prop;
    s = randi([1 r]);
    
    %% Save random particles not scaled
    if s == 1
        imwrite(h, fullfile(saving_folder,strcat(t,'_',temp1.cpType{i},'_',num2str(i),'_scaled','.png')))
        imwrite(framedata,fullfile(saving_folder,strcat(t,'_',temp1.cpType{i},'_',num2str(he),'_height','.png')))
    end
end
end