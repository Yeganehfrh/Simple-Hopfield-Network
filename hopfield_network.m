%Basic structure of Hopfield network
%Yeganeh Farahzadi <y.farahzadi@gmail.com> 5 March 2017
% --------------------------------------------
clc;
clear;

%%Parameters
num_neuron = 10;
num_pattern = 2;
Temperature = 10;

%%Producing Patterns 
rng('shuffle')
for i = 1:num_pattern
    pattern = 2*round(rand(num_neuron,num_pattern))-1;
end

%%Weight matrix
WTotal = zeros(num_neuron,num_neuron);
for ii = 1:num_pattern
    for i = 1:num_neuron
        for j = 1:num_neuron
            if i == j
                Wii(i,j) = 0;
            else
                Wii(i,j) = pattern(i,ii)*pattern(j,ii);
            end
        end
    end
    WTotal = Wii + WTotal;
end

%%Display pattern and get a new pattern
disp('your network is constructed... These are its stable points:');
pattern
disp('give me a new pattern...');
fprintf('keep in mind that your new pattern should have %d neurons\n', num_neuron);
new_pattern = input('give me your new pattern in a column vector... if you want me to produce a new pattern, please just click 1 and press enter');
if new_pattern == 1
    similarity = input('How similar is it to previous patterns?.. say a number between zero and one, then press enter')
    num_newpattern = 1;
    fprintf('your network have learned %d pattern...\n', num_pattern)
    patternorder = input('which of it old patterns do you want to be similar to the new one? please enter its number');
    for i=1:num_neuron
         if rand < similarity
             new_pattern(i) = pattern(i,patternorder);
         elseif rand < .5
             new_pattern(i) = 1;
         else
             new_pattern(i) = -1;
         end
    end
    new_pattern = new_pattern'
    size_newpattern = size(new_pattern);
    num_newcolumn = size_newpattern(1,2);
else
    size_newpattern = size(new_pattern);
    num_newcolumn = size_newpattern(1,2);
end

%%System energy in new pattern
E = 0;
E_newpattern = zeros(1,num_neuron+1);
for ii = 1:num_newcolumn
    for i = 1:num_neuron
        for j = 1:num_neuron
            E = (WTotal(i,j)*new_pattern(i,ii)*new_pattern(j,ii)) + E;
        end
    end
end
E_newpattern(1,1) = -0.5*E;

%%learning new pattern & system energy through learning
probability = zeros(num_neuron,num_newcolumn);
learned_pattern = new_pattern;
for ii = 1:num_newcolumn
    for i = 1:num_neuron
        hi = 0;
        for j = 1:num_neuron
            hi = (WTotal(i,j)*learned_pattern(j,ii)) + hi;
        end
        if hi >= 0
            learned_pattern(i,ii) = 1;
        else
            learned_pattern(i,ii) = -1;
        end
        probability(i,ii) = 1/(1+exp(-T*hi));
        E = 0;
        for ii = 1:num_newcolumn %it works when there is just ONE NEW pattern
             for a = 1:num_neuron
                 for b = 1:num_neuron
                     E = (WTotal(a,b)*learned_pattern(a,ii)*learned_pattern(b,ii)) + E;
                 end
             end
        end
        E_newpattern(1,i+1) = -0.5*E;
    end
end

clear a;
clear b;

pattern
learned_pattern

%%system energy
E_stable = zeros(1,num_pattern+1);
  for ii = 1:num_pattern
      E = 0;
             for i = 1:num_neuron
                 for j = 1:num_neuron
                     E = (WTotal(i,j)*pattern(i,ii)*pattern(j,ii)) + E;
                 end
             end
             E_stable(1,ii) = -0.5*E;
  end

%%Ploting system energy
E_stable(1,num_pattern+1) = E_newpattern(1,num_neuron+1);
num_patterns = 1:num_pattern + num_newpattern;
plot(num_patterns,E_stable,'r--*')
title('Stable points')
xlabel('Pattern numbers')
ylabel('system energy')

figure(2)
plot(E_newpattern,'m--o')
title('System Energy through training new pattern')
xlabel('TimeSteps')
ylabel('system energy')

%Clear junks
clear Wii;
clear hi;
clear i;
clear ii;
clear j;
clear E;
