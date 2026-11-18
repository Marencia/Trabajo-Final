library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Global_types.ALL;

entity tb_BITONIC_8_S is
-- Los testbenches no tienen puertos en su entidad
end tb_BITONIC_8_S;

architecture Behavioral of tb_BITONIC_8_S is

    -- 1. Componente bajo prueba (UUT - Unit Under Test)
    component BITONIC_8_S
        port(
            clk    : in  std_logic;
            reset  : in  std_logic;
            DATOS  : in  VEC_DATOS;
            SALIDA : out VEC_DATOS
        );
    end component;

    -- 2. Señales de estímulo locales
    signal clk    : std_logic := '0';
    signal reset  : std_logic := '0';
    signal DATOS  : VEC_DATOS := (others => (others => '0'));
    signal SALIDA : VEC_DATOS;

    -- 3. Definición del periodo de reloj (ej. 100 MHz -> 10 ns)
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instanciación de la UUT
    uut: BITONIC_8_S
        port map (
            clk    => clk,
            reset  => reset,
            DATOS  => DATOS,
            SALIDA => SALIDA
        );

    -- Generador del reloj de manera continua
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Proceso de estímulos
    stim_proc: process
    begin
        -- === PASO 1: Inicialización y Reset ===
        reset <= '1';
        wait for CLK_PERIOD * 2; 
        reset <= '0';
        wait for CLK_PERIOD; -- Esperar un ciclo para sincronizar

        -- === PASO 2: Ingreso de Datos (Caso de prueba 1) ===
        -- Enviamos un vector desordenado de forma descendente
        -- Supongamos que tu tipo VEC_DATOS contiene std_logic_vector de 8 bits
        DATOS(0) <= std_logic_vector(to_unsigned(80, 8));
        DATOS(1) <= std_logic_vector(to_unsigned(70, 8));
        DATOS(2) <= std_logic_vector(to_unsigned(60, 8));
        DATOS(3) <= std_logic_vector(to_unsigned(50, 8));
        DATOS(4) <= std_logic_vector(to_unsigned(40, 8));
        DATOS(5) <= std_logic_vector(to_unsigned(30, 8));
        DATOS(6) <= std_logic_vector(to_unsigned(20, 8));
        DATOS(7) <= std_logic_vector(to_unsigned(10, 8));
        
        -- El dato 1 entra en el ciclo actual. 
        -- Debido a los registros de pipeline, tardará 6 ciclos de reloj en salir.
        wait for CLK_PERIOD;

        -- === PASO 3: Demostración de Pipeline (Caso de prueba 2) ===
        -- Mientras el caso 1 viaja por las etapas, inmediatamente ingresamos 
        -- un segundo vector con valores aleatorios desordenados.
        DATOS(0) <= std_logic_vector(to_unsigned(15, 8));
        DATOS(1) <= std_logic_vector(to_unsigned(99, 8));
        DATOS(2) <= std_logic_vector(to_unsigned(3,  8));
        DATOS(3) <= std_logic_vector(to_unsigned(45, 8));
        DATOS(4) <= std_logic_vector(to_unsigned(72, 8));
        DATOS(5) <= std_logic_vector(to_unsigned(8,  8));
        DATOS(6) <= std_logic_vector(to_unsigned(54, 8));
        DATOS(7) <= std_logic_vector(to_unsigned(1,  8));

        wait for CLK_PERIOD;
        
		  
		  DATOS(0) <= std_logic_vector(to_unsigned(2,   8));
        DATOS(1) <= std_logic_vector(to_unsigned(23,  8));
        DATOS(2) <= std_logic_vector(to_unsigned(15,  8));
        DATOS(3) <= std_logic_vector(to_unsigned(34,  8));
        DATOS(4) <= std_logic_vector(to_unsigned(25,  8));
        DATOS(5) <= std_logic_vector(to_unsigned(60,  8));
        DATOS(6) <= std_logic_vector(to_unsigned(93,  8));
        DATOS(7) <= std_logic_vector(to_unsigned(84,  8));

        wait for CLK_PERIOD;
		  
		  
		  DATOS(0) <= std_logic_vector(to_unsigned(150, 8));
        DATOS(1) <= std_logic_vector(to_unsigned(7,   8));
        DATOS(2) <= std_logic_vector(to_unsigned(13,  8));
        DATOS(3) <= std_logic_vector(to_unsigned(2,   8));
        DATOS(4) <= std_logic_vector(to_unsigned(1,   8));
        DATOS(5) <= std_logic_vector(to_unsigned(77,  8));
        DATOS(6) <= std_logic_vector(to_unsigned(88,  8));
        DATOS(7) <= std_logic_vector(to_unsigned(22,  8));

        wait for CLK_PERIOD;
		  
		  
		  DATOS(0) <= std_logic_vector(to_unsigned(213, 8));
        DATOS(1) <= std_logic_vector(to_unsigned(88,  8));
        DATOS(2) <= std_logic_vector(to_unsigned(2,   8));
        DATOS(3) <= std_logic_vector(to_unsigned(2,   8));
        DATOS(4) <= std_logic_vector(to_unsigned(50,  8));
        DATOS(5) <= std_logic_vector(to_unsigned(1,   8));
        DATOS(6) <= std_logic_vector(to_unsigned(11,  8));
        DATOS(7) <= std_logic_vector(to_unsigned(77,  8));

        wait for CLK_PERIOD;
		  
		  
        -- Ponemos la entrada a cero para observar visualmente cómo se limpian los datos en el pipeline
        DATOS <= (others => (others => '0'));

        -- === PASO 4: Tiempo de propagación del pipeline ===
        -- Esperamos el tiempo suficiente para ver salir ambos resultados ordenados.
        -- Como pusimos el primer caso, pasará:
        -- - T+1 ciclos: El primer caso avanza a r_etapa_1
        -- - ...
        -- - T+6 ciclos: El primer caso ordenado (10, 20, 30... 80) aparece en SALIDA.
        -- - T+7 ciclos: El segundo caso ordenado (1, 3, 8... 99) aparece en SALIDA.
        wait for CLK_PERIOD * 10;

        -- Finalizar la simulación
        assert false report "Simulacion terminada con exito" severity failure;
        wait;
    end process;

end Behavioral;