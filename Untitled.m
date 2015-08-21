Dictionary=[Cartoon_DictH];
[x y]=size(Dictionary);
k=1;
j=1;
pic=[];
for i=1:size(Cartoon_DictH,2)
%     pic((k-1)*8+1:(k-1)*8+8,(j-1)*8+1:(j-1)*8+8)=imresize(reshape(Texture_Dict(:,i),4,4),2,'bicubic');
    pic((k-1)*zooming*patch_size+1:(k-1)*zooming*patch_size+zooming*patch_size,(j-1)*zooming*patch_size+1:(j-1)*zooming*patch_size+zooming*patch_size)=reshape(Cartoon_DictH(1:(zooming*patch_size)^2,i),zooming*patch_size,zooming*patch_size);
    j=j+1;
    if(mod(i,16)==0)
        k=k+1;
        j=1;
    end
end
pic=pic-min(min(pic));
pic=pic/max(max(pic));
figure;imshow(pic)
imwrite(pic,'Cartoon_Dict.jpg')
Dictionary=[Texture_DictH];
[x y]=size(Dictionary);
k=1;
j=1;
pic=[];
for i=1:size(Texture_DictH,2)
%     pic((k-1)*8+1:(k-1)*8+8,(j-1)*8+1:(j-1)*8+8)=imresize(reshape(Texture_Dict(:,i),4,4),2,'bicubic');
    pic((k-1)*zooming*patch_size+1:(k-1)*zooming*patch_size+zooming*patch_size,(j-1)*zooming*patch_size+1:(j-1)*zooming*patch_size+zooming*patch_size)=reshape(Texture_DictH(1:(zooming*patch_size)^2,i),zooming*patch_size,zooming*patch_size);
    j=j+1;
    if(mod(i,16)==0)
        k=k+1;
        j=1;
    end
end
pic=pic-min(min(pic));
pic=pic/max(max(pic));
figure;imshow(pic)
imwrite(pic,'Texture_Dict.jpg')