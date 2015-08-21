function [Mb]=Pblocky(f1) 
% clear all; 
 
% f1=imread('img80.bmp'); 
f2=rgb2gray(f1); 
 
f=im2double(f2); 
[m,n]=size(f); 
g1=zeros(m,n); g2=zeros(m,n); 
s1=zeros(1,m*n);s2=zeros(1,m*n); 
%水平差异 
for i=1:m 
    for j=1:n 
        if j-1==0 
        g1(i,j)=f(i,j); 
        else 
        g1(i,j)=abs(f(i,j)-f(i,j-1));   
        end 
       s1((i-1)*n+j)=g1(i,j); 
  
    end 
end 
%垂直差异 
for p=1:m 
    for q=1:n 
        if p-1==0 
        g2(p,q)=f(p,q); 
        else 
        g2(p,q)=abs(f(p,q)-f(p-1,q));   
        end 
        s2((q-1)*m+p)=g2(p,q); 
    end 
end 
 
b=1; 
a=m*n; 
for i=1:100 
   if rem(a,2^b)~=0 
       b=b; 
   else 
       b=b+1; 
   end 
end 
 
N=256; 
L=a/N; 
% N=2^(b-1); 
% L=a/N; 
P1=zeros(L,N/2);P2=zeros(L,N/2); 
X1=zeros(1,N);X2=zeros(1,N); 
 
%水平方向 
for k1=1:L 
    for l1=1:N 
        x1(l1)=s1((k1-1)*N+l1);          
    end 
    X1=fft(x1,N); 
    for l11=1:N/2 
        if (l11==0)||(l11==N/2) 
            P1(k1,l11)=abs(X1(l11))^2; 
        else 
            P1(k1,l11)=2*abs(X1(l11))^2; 
        end 
    end 
end 
 
 
%垂直方向 
for k2=1:L 
    for l2=1:N 
        x2(l2)=s2((k2-1)*N+l2); 
    end 
    X2=fft(x2,N); 
    for l12=1:N/2 
        if (l12==0)&&(l12==N/2) 
            P2(k2,l12)=abs(X2(l12))^2; 
        else 
            P2(k2,l12)=2*abs(X2(l12))^2; 
        end 
    end 
end 
 
%水平方向 
P_avg1=1/L*sum(P1,1); 
%中值?波平滑 
kk=(log(N/2)/log(2)-1)/2; 
pp=zeros(1,2*kk+1); 
for p1=1:N/2; 
    for kk1=1:kk 
        if p1-kk1<=0 
            pp(kk1)=P_avg1(p1);   
        else 
            pp(kk1)=P_avg1(p1-kk1); 
        end 
        pp(kk+1)=P_avg1(p1); 
        if p1+kk1>N/2 
            pp(kk+kk1+1)=P_avg1(p1); 
        else 
            pp(kk+kk1+1)=P_avg1(p1+kk1); 
        end 
    end 
    PM(p1)=median(pp); 
end 
 
for n1=1:N/2; 
    if (n1==33)||(n1==65)||(n1==97)||(n1==128) 
        P_avg12(n1)=P_avg1(n1); 
    else 
        P_avg12(n1)=PM(n1); 
    end 
end 
 
Pw1_org=log(1+P_avg1); 
Pw1=log(1+P_avg12); 
PwM=log(1+PM); 
 
Mbh=8/7*(P_avg1(N/8+1)-PM(N/8+1)+P_avg1(2*N/8+1)-PM(2*N/8+1)+P_avg1(3*N/8+1)-PM(3*N/8+1)+P_avg1(4*N/8)-PM(4*N/8)); 
% disp(Mbh); 
 
n11=1:N/2; 
ff1=n11/N; 
% figure (1); 
subplot(121); 
plot(ff1,Pw1_org,'b',ff1,Pw1,'r'); 
xlabel('?率'); 
ylabel('Power(log(1+P(l))'); 
title('水平方向求差?像功率?'); 
 
%垂直方向 
P_avg2=1/L*sum(P2,1); 
%中值?波平滑 
kkk=(log(N/2)/log(2)-1)/2; 
ppp=zeros(1,2*kkk+1); 
 
for pp1=1:N/2; 
     
    for kkk1=1:kk 
        if pp1-kkk1<=0 
            ppp(kkk1)=P_avg2(pp1);   
        else 
            ppp(kkk1)=P_avg2(pp1-kkk1); 
        end 
        ppp(kkk+1)=P_avg2(pp1); 
        if pp1+kkk1>N/2 
            ppp(kkk+kkk1+1)=P_avg2(pp1); 
        else 
            ppp(kkk+kkk1+1)=P_avg2(pp1+kkk1); 
        end 
    end 
    PMM(pp1)=median(ppp); 
end 
 
for n1=1:N/2; 
    if (n1==33)||(n1==65)||(n1==97)||(n1==128) 
        P_avg22(n1)=P_avg2(n1); 
    else 
        P_avg22(n1)=PMM(n1); 
    end 
end 
 
Pw2_org=log(1+P_avg2); 
Pw2=log(1+P_avg22); 
PwMM=log(1+PMM); 
 
Mbv=8/7*(P_avg2(N/8+1)-PMM(N/8+1)+P_avg2(2*N/8+1)-PMM(2*N/8+1)+P_avg2(3*N/8+1)-PMM(3*N/8+1)+P_avg2(4*N/8)-PMM(4*N/8)); 
% disp(Mbv); 
Mb=0.5*(Mbh+Mbv); 
 disp(Mb); 
 
n21=1:N/2; 
ff2=n21/N; 
% figure(2); 
subplot(122); 
plot(ff2,Pw2_org,'b',ff2,Pw2,'r'); 
xlabel('?率'); 
ylabel('Power(log(1+P(l))'); 
title('垂直方向求差?像功率?'); 
