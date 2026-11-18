library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Global_types.ALL;

entity tb_B_N_S_SERIE is
end tb_B_N_S_SERIE;

architecture sim of tb_B_N_S_SERIE is

    -- Señales de estímulo
    signal clk    : std_logic := '0';
    signal reset  : std_logic := '0';
    signal DATOS  : std_logic_vector(N_BITS-1 downto 0) := (others => '0');
    
    -- Señal de salida (vector completo con los 16 elementos ordenados)
    signal SALIDA : VEC_DATOS;

    -- Período del reloj (ej: 10 ns -> 100 MHz)
    constant CLK_PERIOD : time := 10 ns;

    -- Tipo y matriz para almacenar los 16 números de prueba (8 bits cada uno)
    type t_test_array is array (0 to 15) of std_logic_vector(N_BITS-1 downto 0);
    
    -- Datos de prueba desordenados (16 valores de 8 bits)
    constant TEST_DATA : t_test_array := (
        std_logic_vector(to_unsigned(45, N_BITS)),
        std_logic_vector(to_unsigned(12, N_BITS)),
        std_logic_vector(to_unsigned(89, N_BITS)),
        std_logic_vector(to_unsigned(3,  N_BITS)),
        std_logic_vector(to_unsigned(76, N_BITS)),
        std_logic_vector(to_unsigned(23, N_BITS)),
        std_logic_vector(to_unsigned(1,  N_BITS)),
        std_logic_vector(to_unsigned(99, N_BITS)),
        std_logic_vector(to_unsigned(54, N_BITS)),
        std_logic_vector(to_unsigned(32, N_BITS)),
        std_logic_vector(to_unsigned(11, N_BITS)),
        std_logic_vector(to_unsigned(88, N_BITS)),
        std_logic_vector(to_unsigned(65, N_BITS)),
        std_logic_vector(to_unsigned(4,  N_BITS)),
        std_logic_vector(to_unsigned(33, N_BITS)),
        std_logic_vector(to_unsigned(7,  N_BITS))
    );

begin

    -- Instanciación de la Unidad Bajo Prueba (UUT)
    uut: entity work.B_N_S_SERIE
        port map (
            clk    => clk,
            reset  => reset,
            DATOS  => DATOS,
            SALIDA => SALIDA
        );

    -- Generador de Reloj
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Proceso de Estímulos (Inyección Serie)
    stim_process : process
    begin
        -- 1. Aplicar Reset inicial
        reset <= '1';
        DATOS <= (others => '0');
        wait for CLK_PERIOD * 3;
        reset <= '0';
        wait for CLK_PERIOD;

        -- 2. Inyectar los 16 datos uno por ciclo de reloj de forma serie
        for i in 0 to N_DATOS-1 loop
            DATOS <= TEST_DATA(i);
            wait for CLK_PERIOD;
        end loop;

        -- 3. Dejar de inyectar datos relevantes (ceros o lo que prefieras)
        DATOS <= (others => '0');

        -- 4. Esperar a que la tubería (pipeline) procese y propague las etapas
        -- El total de etapas depende de tu función N_ETAPAS(16). Dejamos un margen de ciclos.
        wait for CLK_PERIOD * 25;

        -- Fin de la simulación
        assert false report "Simulación finalizada con éxito." severity note;
        wait;
    end process;

end sim;