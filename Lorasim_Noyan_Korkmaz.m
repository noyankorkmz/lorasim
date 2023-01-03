%Noyan Korkmaz 031911546 LoRaWAN Mühendislik Tasarımı 1
clear all
SF = 20; %yayılma faktörü
BW = 1000; %bant genişliği
Fs = 1000; %frekans
s = 33; %sembol 
SNR = -10 %signal to noise ratio

%------------data sembollerini generate ediyoruz-------------------
num_samples =(2^SF)*Fs/BW;
k=s; %s'i k'ya entegre ediyorum (data sembolünü belirliyor)
lora_symbol =zeros(1,num_samples);
for n=1:num_samples
    if k>= (2^SF)
        k = k-2^SF;
    end
    k = k+1;
    lora_symbol(n) = (1/(sqrt(2^SF)))*exp(1i*2*pi*(k)*(k/(2^SF*2)));
end

for j=1:100
    %noise ekliyoruz
    lora_symbol_noisy = awgn(lora_symbol,SNR,'measured');
    %İletim
    %alıcı işlemleri
    %------------Base Down Chirp generatörü----------
    base_down_chirp = zeros(1,num_samples);
    k=0;
    for n=1:num_samples
        if k>= (2^SF)
            k = k-2^SF;
        end
        k = k + 1;
        base_down_chirp(n) = (1/(sqrt(2^SF)))*exp(-1i*2*pi*(k)*(k/(2*SF*2)));
    end
    dechirped = lora_symbol_noisy.*(base_down_chirp);

    corrs = (abs(fft(dechirped)).^2);
    plot(corrs)
    [~,ind] = max(corrs);
    ind2(j) = ind;

    pause(0.01)
end

histogram(ind2,2^SF)

symbol_error_rate = sum(ind2~=s+1)/j

%spectrogram(lora_symbol)