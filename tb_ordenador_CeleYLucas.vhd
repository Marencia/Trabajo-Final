library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_ordenador_CeleYLucas is
end entity tb_ordenador_CeleYLucas;

architecture sim of tb_ordenador_CeleYLucas is

    -- 1. CONFIGURACIÓN PARA 512 ELEMENTOS DE 32 BITS
    constant C_NBITS    : natural := 32;
    constant C_NELEM    : natural := 512;
    constant CLK_PERIOD : time    := 10 ns;

    -- Declaración del componente
    component ordenador_CeleYLucas is
        generic(
            Nbits : NATURAL := 32;
            Nelem : NATURAL := 512
        );
        port(
            clk      : in  std_logic;
            rst      : in  std_logic;
            hab      : in  std_logic;
            dato_in  : in  std_logic_vector(Nbits - 1 downto 0);
            Q        : out std_logic_vector(Nbits - 1 downto 0)
        );
    end component;

    -- Señales de estímulo
    signal clk     : std_logic := '0';
    signal rst     : std_logic := '0';
    signal hab     : std_logic := '0';
    signal dato_in : std_logic_vector(C_NBITS - 1 downto 0) := (others => '0');
    signal Q       : std_logic_vector(C_NBITS - 1 downto 0);
    signal sim_finished : boolean := false;

begin

    -- Instanciación con los nuevos genéricos
    DUT: ordenador_CeleYLucas
        generic map(
            Nbits => C_NBITS,
            Nelem => C_NELEM
        )
        port map(
            clk     => clk,
            rst     => rst,
            hab     => hab,
            dato_in => dato_in,
            Q       => Q
        );

    -- Generador de Clock (100 MHz)
    process
    begin
        while not sim_finished loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Proceso de estímulos para 512 elementos
    process
    begin
        -- 1. Reset
        rst <= '0';
        hab <= '0';
        dato_in <= (others => '0');
        wait for CLK_PERIOD * 2;

        wait until falling_edge(clk);
        rst <= '1';
        wait for CLK_PERIOD;

        ------------------------------------------------------------------
        -- FASE 1: CARGA DE 512 DATOS (hab = '0')
        -- Inyectamos datos en orden inverso: 512, 511, 510... hasta 1
        ------------------------------------------------------------------
        report "--- Iniciando carga serie de 512 datos ---";
        hab <= '0';
        
        for i in 0 to C_NELEM - 1 loop
            -- Valor descendente para exigir al algoritmo
            dato_in <= std_logic_vector(to_unsigned(C_NELEM - i, C_NBITS));
            wait until rising_edge(clk);
        end loop;

        dato_in <= (others => '0');

        ------------------------------------------------------------------
        -- FASE 2: ORDENAMIENTO (hab = '1')
        -- Odd-Even Sort requiere al menos Nelem ciclos completos
        ------------------------------------------------------------------
        report "--- Ordenando 512 elementos durante 512 ciclos ---";
        hab <= '1';
        wait for CLK_PERIOD * C_NELEM;

        ------------------------------------------------------------------
        -- FASE 3: DESPLAZAMIENTO Y SALIDA POR Q (hab = '0')
        -- Leemos los 512 datos ordenados
        ------------------------------------------------------------------
        report "--- Leyendo salida ordenada por Q ---";
        hab <= '0';

        for i in 0 to C_NELEM - 1 loop
            wait until rising_edge(clk);
            report "Q(" & integer'image(i) & ") = " & 
                   integer'image(to_integer(unsigned(Q)));
        end loop;

        wait for CLK_PERIOD * 5;
        report "--- Simulación de 512 elementos completada ---" severity note;
        sim_finished <= true;
        wait;
    end process;

end architecture sim;