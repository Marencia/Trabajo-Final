library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Global_types.ALL;


entity B_N_S_SERIE is
    port(
        clk    : in  std_logic;
        reset  : in  std_logic;
        DATOS  : in  std_logic_vector(N_BITS-1 downto 0);
        SALIDA : out VEC_DATOS
    );
end B_N_S_SERIE;

architecture Behavior of B_N_S_SERIE is

   --================================================================================
	-- SEÑALES DE SALIDA DE COMBINACIONAL DE BM-Xs
   --================================================================================
	signal ETAPAS_N     : VEC_ETAPAS;
	
   --================================================================================
	-- SEÑALES DE ENTRADA Y SALIDA PARA REGISTROS
   --================================================================================ 
	
	signal R_ETAPAS_N: VEC_REGISTROS;
   signal r_salida  :     VEC_DATOS;
	
	constant FASE_N 	 : natural := N_FASES(N_DATOS); -- constante con cantidad de fases (par N=8 son 3)
	constant TOTAL_E	 : natural := N_ETAPAS(N_DATOS); -- 
	
begin

	--=================PRUEBA NUEVA=====================--
	
	FOR_FASES: for i in 0 to FASE_N-1 generate
				  begin				  
				  FOR_ETAPAS: for j in 0 to i generate
										
									constant fila   : natural := GET_FILA(i,j);
									constant DIST_O : natural :=    2 ** (i-j);
									
									begin
									FOR_XOR: for k in 0 to N_DATOS - 1 generate 
									constant DIST_ACT : natural := to_integer(to_unsigned(k, FASE_N + 1) xor to_unsigned(DIST_O, FASE_N + 1));	-- comparacion bit a bit para calcular distancia entre elementos
									
													begin
													GEN_PAR: if DIST_ACT > k generate 
																constant ES_UP : boolean := ((k / (2 ** (i + 1))) mod 2) = 0;
																
																begin
																GEN_UP : if ES_UP generate
																		CAS_UP: entity work.CAS_UP
																		port map(
																			D1 => R_ETAPAS_N(fila)(k), D2 => R_ETAPAS_N(fila)(DIST_ACT),
																			Y1 => ETAPAS_N(fila)(k),   Y2 => ETAPAS_N(fila)(DIST_ACT)
																		);
																			end generate GEN_UP;
																GEN_DOWN: if not ES_UP generate
																		CAS_DOWN: entity work.CAS_DOWN
																		port map(
																			D1 => R_ETAPAS_N(fila)(k), D2 => R_ETAPAS_N(fila)(DIST_ACT),
																			Y1 => ETAPAS_N(fila)(k),   Y2 => ETAPAS_N(fila)(DIST_ACT)
																		);
																		end generate GEN_DOWN;
													end generate GEN_PAR;								
											  end generate FOR_XOR;
								 end generate FOR_ETAPAS;
					end generate FOR_FASES;			


    --====================================================================
    -- PROCESO SÍNCRONO
    --====================================================================
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
					for s in 0 to TOTAL_E loop -- resetea hasta los registros de salida
							R_ETAPAS_N(s) <= (others => (others => '0')); -- Inicialización de todos los registros en cero
					end loop;
				else
				-- Captura de datos en cada flanco de reloj
				-- Tengo que tomar dato por dato a la entrada y luego ir registrandolos a medida que desplaza
			   -- R desplazados
                for s in 0 to (N_DATOS - 2) loop
						R_ETAPAS_N(0)(s + 1) <= R_ETAPAS_N(0)(s); 
					 end loop;
				R_ETAPAS_N(0)(N_DATOS - 1) <= DATOS;
				
				-- R intermedios
                for j in 0 to TOTAL_E - 1 loop -- carga hasta el registro etapa + 1 que voy a tomar como r_salida
						R_ETAPAS_N(j + 1) <= ETAPAS_N(j); 
					 end loop;
					 

            end if;
        end if;
    end process;

    --================================================================
    -- ASIGNACIÓN DE SALIDA FÍSICA
    --================================================================
    SALIDA <= R_ETAPAS_N(TOTAL_E);

end Behavior;