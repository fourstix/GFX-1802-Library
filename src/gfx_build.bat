[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_check_bounds.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_adj_bounds.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_check_overlap.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_draw_pixel.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_bitmap.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_draw_bitmap.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_ascii_font.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_char.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_draw_char.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_rect.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_block.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_draw_rect.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_fill_rect.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_s_line.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_write_line.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_steep_flag.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS gfx_draw_line.asm


type gfx_check_bounds.prg gfx_adj_bounds.prg gfx_check_overlap.prg > gfx.lib
type gfx_draw_pixel.prg gfx_write_bitmap.prg gfx_draw_bitmap.prg  >> gfx.lib
type gfx_ascii_font.prg gfx_write_char.prg gfx_draw_char.prg >> gfx.lib
type gfx_write_rect.prg gfx_write_block.prg gfx_draw_rect.prg >> gfx.lib
type gfx_fill_rect.prg gfx_write_s_line.prg gfx_write_line.prg >> gfx.lib
type gfx_steep_flag.prg gfx_draw_line.prg >> gfx.lib

copy gfx.lib ..\lib\gfx.lib
