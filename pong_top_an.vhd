-- Listing 12.6
library ieee;
use ieee.std_logic_1164.all;
entity pong_top_an is
   port (
      clk,reset: in std_logic;
      btn: in std_logic_vector (1 downto 0);
      hsync, vsync: out  std_logic;
      rgb: out std_logic_vector(11 downto 0);
      led: out std_logic_vector (7 downto 0);
      ps2d, ps2c: in std_logic
   );
end pong_top_an;

architecture arch of pong_top_an is
   signal pixel_x, pixel_y: std_logic_vector (9 downto 0);
   signal video_on, pixel_tick: std_logic;
   signal k_done_tick, k_press ,k_normal: std_logic;
   signal k_key: std_logic_vector(7 downto 0);
	--mudando para 8 bits da Nexys2
   signal rgb_reg, rgb_next: std_logic_vector(11 downto 0);
begin
   -- instantiate VGA sync
   vga_sync_unit: entity work.vga_sync
      port map(clk=>clk, reset=>reset,
               video_on=>video_on, p_tick=>pixel_tick,
               hsync=>hsync, vsync=>vsync,
               pixel_x=>pixel_x, pixel_y=>pixel_y);
   -- instantiate graphic generator
   pong_graph_an_unit: entity work.pong_graph_animate
      port map (clk=>clk, reset=>reset,
                btn=>btn, video_on=>video_on,
                pixel_x=>pixel_x, pixel_y=>pixel_y,
                graph_rgb=>rgb_next,
                k_done_tick => k_done_tick,
                k_press => k_press,
                k_normal => k_normal,
                k_key => k_key);
   -- rgb buffer
   --instantiate keyboard
       keyboard_unit: entity work.kb_code(arch)
           port map(
               clk => clk,
               reset => reset,
               ps2c => ps2c,
               ps2d => ps2d,           
               k_done_tick => k_done_tick,
               k_press => k_press,
               k_normal => k_normal,
               k_key => k_key,
               rd_key_code => '1'
   );
   process (clk)
   begin
      if (clk'event and clk='1') then
         if (pixel_tick='1') then
            rgb_reg <= rgb_next;
         end if;
      end if;
   end process;
   led <= k_key;
   rgb <= rgb_reg;
end arch;