%% Standard atmosphere
% This script compute the atmospheric coefficient using the International 
% Standard Atmosphere model (ISA). The value of temperature are obtained
% using a linear interpolation between the different layer of atmosphere.
% Each layer has it's own slope and initial temperature. Those values can
% be found at [TODO]. 
% We made the assumption that the atmosphere is hydrostatic. The
% temperature is linearly interpolated in a layer.

% in    alt : The altitude at which the coefficients will be evaluate
% in    env : The environement of the simulation

% out   T : The temperature at this altitude
% out   a : speed of sound
% out   p : pressure
% out   rho : density
% out   nu : viscosity

% Warning : The temperature has to be continu
% Warning : Check that the non differenciability of the temperature doesn't
% affect the quality of the simulation.

function [T, a, p, rho, nu] = atmosphere(alt, env)
    % Check that altitude isn't greater than 100 km
    if alt > 1e5
        disp(['ERROR [atmosphere] : The altitude is out of range: max 100km.' ...
            'return maximum value at 100km'])
        alt = 1e5;
    end

    % Constant
    r_earth = 6378137;              % [m] Radius of earth
    R_star = 287.04;                % [J / (kg K)] real gas constant of air (R0 / M_air)
    gamma = 1.4;                    % [-] specific heat coefficient of air

    % Initial
    p0 = 101325;                    % [Pa] Pressure at sea level
    T0 = atmosphere_temperature(0); % [K] temperature at sea level
    g0 = 9.80665;                   % [m/sec^2] gravity at sea level
    cp = 1.00468506;                % [J / (kg K)] Specific heat at constant pressure 

    % Evaluate the gravity at the given altitude
    g = g0*(r_earth/(r_earth+alt))^2;
    
    % Evaluate temperature using ISA
    T = atmosphere_temperature(alt);

    % Evaluate speed of sound
    % Source : https://en.wikipedia.org/wiki/Speed_of_sound
    a = sqrt(gamma * R_star * T);

    % Pressure
    %p = p0 * (1 - g * alt / (cp * T0)) ^ (cp / R_star);
    p = p0 * exp(- g * alt / (T0 * R_star));

    % Density (ideal gas law)
    rho = p / (T * R_star);
    
    % Viscosity
    % Source https://www.grc.nasa.gov/www/k-12/airplane/viscosity.html
    mu = 1.458 * 1e-6 * T^1.5 / (T + 110.4); % Dynamic viscosity
    nu = mu / rho; % Kinematic viscosity
end

function T = atmosphere_temperature(alt)
    % Table of the International Atmospheric Model
    % Source : https://en.wikipedia.org/wiki/International_Standard_Atmosphere
    table_isa_alt = [0,      11019,  20063,  32162,  47350,  51413,  71802,  86000];
    table_isa_tem = [288.15, 216.65, 216.65, 228.65, 270.65, 270.65, 214.15, 186.95];

    % Check if the altitude is in range
    if alt < table_isa_alt(1) || alt >= table_isa_alt(end)
        T = table_isa_tem(end);
    else
        % Find the interval index
        for i = 1:length(table_isa_alt)-1
            if alt >= table_isa_alt(i) && alt < table_isa_alt(i+1)
                index = i;
                break;
            end
        end

        % Interpolate the temperature
        alt1 =  table_isa_alt(index);
        alt2 =  table_isa_alt(index+1);
        T1 =    table_isa_tem(index);
        T2 =    table_isa_tem(index+1);
        
        T = T1 + (alt - alt1) * (T2 - T1)/(alt2 - alt1);
    end
end








