clc
clear

sir_values = 0:30;
merged_data = [];
merged_bits = [];
merged_bpsk = [];
merged_lfm = [];
merged_phases = [];
total_data = [];
merged_bpsk_stft = [];

for sir = sir_values
    % 파일 이름을 생성합니다.
    filename = sprintf('/home2/LIG/BPSK_LFM_Overlap_v3/sir_%d_dB.mat', sir);
    
    % mat 파일을 로드합니다.
    load(filename)
    
    % 데이터에서 원하는 부분을 추출합니다.
    extracted_data = overlap_stft(86:100,:,:);
    extracted_bits = bits(86:100,:);
    extracted_bpsk = bpsk_iq(86:100,:);
    extracted_lfm = lfm_stft(86:100,:,:);
    extracted_phases = phases(86:100,:);
    extracted_bpsk_stft = bpsk_stft(86:100,:,:);
    
    
    % 병합된 데이터에 추출된 데이터를 추가합니다.
    if isempty(merged_data)
        merged_data = extracted_data;
        merged_bits = extracted_bits;
        merged_bpsk = extracted_bpsk;
        merged_lfm = extracted_lfm;
        merged_phases = extracted_phases;
        merged_bpsk_stft = extracted_bpsk_stft;
        total_data = overlap_stft;
    else
        merged_data = cat(1, merged_data, extracted_data);
        merged_bits = cat(1, merged_bits, extracted_bits);
        merged_bpsk = cat(1, merged_bpsk, extracted_bpsk);
        merged_lfm = cat(1, merged_lfm, extracted_lfm);
        total_data = cat(1, merged_lfm, extracted_lfm);
        merged_bpsk_stft = cat(1, merged_bpsk_stft, extracted_bpsk_stft); 
        merged_phases = cat(1, merged_phases, extracted_phases); 
     
    end
end
save('merged_data_and_bits_30_ver2.mat', 'merged_data', 'merged_bits','merged_bpsk','merged_lfm','total_data','merged_bpsk_stft','merged_phases');
%% step 2
clc
clear
load('pred_label_iq_bpsk_complex_30_ver2.mat')
load('merged_data_and_bits_30_ver2.mat')

fs = 1000;  
window_size = 128;
overlap = 124;
nfft = 128;
window = hann(window_size);

restored_stft = pred_label;


% sample = squeeze(restored_stft(1,:,:));
% sample_IQ = istft(sample, fs, 'Window', window, 'OverlapLength', overlap, 'FFTLength', nfft);
sir_accuracies = zeros(1, 30);
sir_bits = 15;
num_sirs = 30;
bit_errors = zeros(1,num_sirs);

for number = 1:450
    
    sample_iq = real(istft(squeeze(restored_stft(number,:,:)), fs, 'Window', window, 'OverlapLength', overlap, 'FFTLength', nfft));
    % sample_iq(1:8)= 0;
    % sample_iq(end-7:end) = 0;
    
    answer_stft = squeeze(merged_bpsk_stft(number,:,:));
    answer_iq = real(istft(answer_stft, fs, 'Window', window, 'OverlapLength', overlap, 'FFTLength', nfft));
    
    num_samples = length(answer_iq);
    num_bits = num_samples / 4;
    % 변환된 비트를 저장할 배열을 초기화합니다.

    converted_bits = zeros(1, num_bits);
    bits = zeros(1, num_bits);
    
    % 4개의 샘플마다 하나의 비트로 변환합니다.
    for i = 1:num_bits
        sum_samples = sum(sample_iq((i-1)*4+1:i*4));
        if sum_samples > 0
            converted_bits(i) = 1;
        else
            converted_bits(i) = 0;
        end
    end
   
    % 4개의 샘플마다 하나의 비트로 변환합니다.
    for i = 1:num_bits
        sum_samples = sum(answer_iq((i-1)*4+1:i*4));
        if sum_samples > 0
            bits(i) = 1;
        else
            bits(i) = 0;
        end
    end
    num_matched_elements = sum(bits == converted_bits);
    accuracy = num_matched_elements / length(bits) * 100;
    % fprintf('Accuracy: %.2f%%\n', accuracy);
    sir_index = ceil(number/15);
    
    % 해당 SIR에 대한 정확도를 배열에 추가
    sir_accuracies(sir_index) = sir_accuracies(sir_index) + accuracy;
    bit_error = sum(bits~=converted_bits);
    sir_index = ceil(number / sir_bits);
    bit_errors(sir_index) = bit_errors(sir_index) + bit_error;

end


% 각 SIR에 대한 정확도의 평균을 계산
sir_accuracies = sir_accuracies / 15;
% 각 SIR에 대한 bit error rate를 계산합니다.
bit_error_rate = bit_errors / (num_samples / 4) / sir_bits;

% 전체 평균 정확도를 계산
mean_accuracy = mean(sir_accuracies);

fprintf('Mean Accuracy: %.2f%%\n', mean_accuracy);
%%
SIR = 0:20; % SIR 범위 생성
accuracies = sir_accuracies; % accuracy 값들을 의미하는 변수

figure; % 새로운 그림 창 생성
plot(SIR, accuracies(1:21), 'o-'); % plot 그리기

xlabel('SIR'); % x축 레이블 설정
ylabel('Accuracy'); % y축 레이블 설정
title('Accuracy vs SIR'); % 그래프 제목 설정
grid on; % 그리드 표시

% sample = squeeze(abs(restored_stft(2,:,:)));
% imagesc(sample)
%%
SIR = 0:-1:-20; % SIR values from 0 to -20
figure; % Create new figure window
semilogy(SIR, bit_error_rate(1:21), 'o-'); % Plot graph with log scale on y-axis
mean_err = mean(bit_error_rate);
xlabel('SIR', 'FontName', 'Times New Roman'); % Set x-axis label with font
ylabel('Bit Error Rate', 'FontName', 'Times New Roman'); % Set y-axis label with font
title('Bit Error Rate vs SIR(BPSK)', 'FontName', 'Times New Roman'); % Set title of the graph with font
grid on; % Display grid

% Save the figure as a high-resolution PNG file
print('-dpng', '-r300', 'post_img.png')
