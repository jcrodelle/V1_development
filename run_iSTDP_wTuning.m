clear all
seed = 2000;
N = 256;% number of cortical neurons -- a square number
Tfin = 1200.0;  % in seconds
fback = 0.02; %0.05 is the strength for any spikes without LGN input
A3_LTP = 0.005;
A3_LTP_cort = 0.015; 
A_iSTDP = 0.008;
gmax = 0.02;
%numGJs = 150;
R0 = 5.0;
targetRate = 8.0;
gmax_cortical = 0.025;  %for rad connect
%gmax_cortical = 0.003;  % for all-to-all
seed_tuning = 210;
T_stim = 3000.0;
probGJs_vec = [0.0]; %0.02 0.05 0.1]; %[0.0 0.1];
cortLearnTime = [250]; %[200 300 400 500];
flagflagNonZeroStrength = 1; %flag==0 starts coritcal weights at 0, flag==1 starts them at a distribution

executable = 'learning_trip_iSTDP_diffRates';
command1 = ['rm ', executable];
system(command1)
command2 = 'g++ -lm -Wall -O2 tripletRule_fullSim_iSTDP_diffRates_radConn.cpp -o learning_trip_iSTDP_diffRates';
system(command2);
path = '/Users/JenniferKile/Documents/CIMS_research/MATLAB_things/tripletRule_model/networkTriplet_iSTDP/data_diffRates/';

for i = 1:length(probGJs_vec)
    for j = 1:length(cortLearnTime)
        timeForSynapses = cortLearnTime(j);
        probGJs = probGJs_vec(i);
        a = [seed Tfin*1000 N fback R0 A3_LTP A3_LTP_cort A_iSTDP gmax probGJs targetRate gmax_cortical,timeForSynapses*1000, flagflagNonZeroStrength];
        B = ['./', num2str(executable),' ', num2str(a)]
        command3 = B;   % run code
        system(command3)
         
        
        endName = ['_iSTDP_radConnect',num2str(N),'cells_rate',num2str(targetRate),'_',num2str(100*probGJs),'PercentSisterGJs_',num2str(timeForSynapses),'sCortLearn_seed',num2str(seed),'_wLGNinhib_take2'];
      %  endName = ['_iSTDP_allToAll',num2str(N),'cells_rate',num2str(targetRate),'_',num2str(100*probGJs),'PercentSisterGJs_',num2str(timeForSynapses),'sCortLearn_seed',num2str(seed),'_wLGNinhib_take3'];
       
        name = ['tripletRule_',num2str(Tfin),'s',endName];
        movefile('LGNweights_final.csv',['','LGNweights_final_',name,'.csv']);
                
% %         tuningName = '';
        executable_tuning = 'tuningModel';
        command_tuning = ['rm ', executable_tuning];
        system(command_tuning)
        command4 = 'g++ -lm -Wall -O2 toyModel_makeTuningCurve_wGJ.cpp -o tuningModel';
        system(command4);
        a2 = [seed_tuning T_stim N];
        B2 = ['./', num2str(executable_tuning),' ', num2str(a2),' ', name]
        command5 = B2;   % run code
        system(command5)
        
        movefile('tuningInfo.csv',[path,'tuningInfo_',name,'_FINAL.csv']);
        movefile('weightMatrix_synapses.csv', [path,'weightMatrix_synapses_',name,'.csv']);
        movefile('weightMatrix_cortex.csv', [path,'weightMatrix_cortex_',name,'.csv']);
        movefile('parameters.txt', [path,'parameters_',name,'.txt']);
        movefile('neuronSpTimes.csv',[path,'neuronSpTimes_',name,'.csv']);
        movefile('electricConnections.csv',[path,'electricConnections_',name,'.csv']);
    end
end