
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ZX_01_OUTPUT_FZX
; romless driver for proportional fzx fonts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Windowed output terminal for proportional fzx fonts.
; Implements tty_z88dk terminal emulation.
;
; ;;;;;;;;;;;;;;;;;;;;
; DRIVER CLASS DIAGRAM
; ;;;;;;;;;;;;;;;;;;;;
;
; CONSOLE_01_OUTPUT_TERMINAL (root, abstract)
; CONSOLE_01_OUTPUT_TERMINAL_FZX (abstract)
; ZX_01_OUTPUT_FZX (concrete)
; ZX_01_OUTPUT_FZX_TTY_Z88DK (concrete)
;
; Can be instantiated to implement a CONSOLE_01_OUTPUT_TERMINAL.
;
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MESSAGES CONSUMED FROM STDIO
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; * STDIO_MSG_PUTC
;   Generates multiple OTERM_MSG_PUTC messages.
;
; * STDIO_MSG_WRIT
;   Generates multiple OTERM_MSG_PUTC messages.
;
; * STDIO_MSG_SEEK -> no error, do nothing
; * STDIO_MSG_FLSH -> no error, do nothing
; * STDIO_MSG_ICTL
; * STDIO_MSG_CLOS -> no error, do nothing
;
; Any other messages are reported as errors via
; error_enotsup_zc
;
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MESSAGES CONSUMED FROM CONSOLE_01_OUTPUT_TERMINAL
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   * OTERM_MSG_PUTC
;
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MESSAGES CONSUMED FROM CONSOLE_01_INPUT_TERMINAL
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   * ITERM_MSG_PUTC
;   * ITERM_MSG_PRINT_CURSOR
;   * ITERM_MSG_BS
;   * ITERM_MSG_BS_PWD
;   * ITERM_MSG_ERASE_CURSOR
;   * ITERM_MSG_ERASE_CURSOR_PWD
;   * ITERM_MSG_READLINE_BEGIN
;   * ITERM_MSG_READLINE_END
;   * ITERM_MSG_BELL
;
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MESSAGES CONSUMED FROM CONSOLE_01_OUTPUT_TERMINAL_FZX
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   * OTERM_MSG_TTY
;   * OTERM_MSG_BELL
;   * OTERM_MSG_SCROLL
;   * OTERM_MSG_CLS
;   * OTERM_MSG_PAUSE
;
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MESSAGES CONSUMED FROM ZX_01_OUTPUT_FZX
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   * OTERM_MSG_SCROLL
;
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MESSAGES GENERATED FOR DERIVED DRIVERS
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   * ITERM_MSG_READLINE_SCROLL_LIMIT (optional)
;
;     enter  :  c = default
;     exit   :  c = number of rows to scroll before pause
;     can use:  af, bc, de, hl
;
;     Return number of scrolls allowed before pause after
;     a readline operation ends.  Default is current y + 1.
;
;   * OTERM_MSG_SCROLL_LIMIT (optional)
;
;     enter  :  c = default
;     exit   :  c = maximum scroll amount
;     can use:  af, bc, de, hl
;
;     Scroll has just paused.  Return number of scrolls until
;     next pause.  Default is window height.
;
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IOCTLs UNDERSTOOD BY THIS DRIVER
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   * IOCTL_OTERM_CRLF
;     enable / disable crlf processing
;
;   * IOCTL_OTERM_BELL
;     enable / disable terminal bell
;
;   * IOCTL_OTERM_SIGNAL
;     enable / disable signal bell
;
;   * IOCTL_OTERM_COOK
;     enable / disable cook mode (tty emulation)
;
;   * IOCTL_OTERM_PAUSE
;     enable / disable pause when window filled
;
;   * IOCTL_OTERM_PAGE
;     select scroll or page mode
;
;   * IOCTL_OTERM_CLEAR
;     enable / disable clear window when in page mode
;
;   * IOCTL_OTERM_CLS
;     clear window, set (x,y) = (0,0)
;
;   * IOCTL_OTERM_RESET_SCROLL
;     reset scroll count
;
; THE FZX WINDOW IS THE AREA THAT IS CLEARED AND SCROLLED
;
;   * IOCTL_OTERM_GET_WINDOW_COORD
;     get coord of top left corner of window
;
;   * IOCTL_OTERM_SET_WINDOW_COORD
;     set coord of top left corner of window
;
;   * IOCTL_OTERM_GET_WINDOW_RECT
;     get window size
;
;   * IOCTL_OTERM_SET_WINDOW_RECT
;     set window size
;
;   * IOCTL_OTERM_GET_CURSOR_COORD
;
;   * IOCTL_OTERM_SET_CURSOR_COORD
;
;   * IOCTL_OTERM_GET_OTERM
;
;   * IOCTL_OTERM_SCROLL
;
;   * IOCTL_OTERM_SCROLL_LIMIT
;
;   * IOCTL_OTERM_FONT
;
; THE FZX PAPER IS THE AREA WHERE PRINTING OCCURS
; THE FZX WINDOW CONTAINS THE FZX PAPER
;
;   * IOCTL_OTERM_FZX_GET_PAPER_COORD
;     get coord of top left corner of paper
;
;   * IOCTL_OTERM_FZX_SET_PAPER_COORD
;     set coord of top left corner of paper
;
;   * IOCTL_OTERM_FZX_GET_PAPER_RECT
;     get paper size
;
;   * IOCTL_OTERM_FZX_SET_PAPER_RECT
;     set paper size
;
;   * IOCTL_OTERM_FZX_LEFT_MARGIN
;
;   * IOCTL_OTERM_FZX_LINE_SPACING
;
;   * IOCTL_OTERM_FZX_SPACE_EXPAND
;
;   * IOCTL_OTERM_FZX_GET_FZX_STATE
;
;   * IOCTL_OTERM_FZX_SET_FZX_STATE
;
;   * IOCTL_OTERM_BCOLOR
;
;   * IOCTL_OTERM_FCOLOR
;
;   * IOCTL_OTERM_FMASK
;
; ;;;;;;;;;;;;;;;;;;;;;;;;;;
; BYTES RESERVED IN FDSTRUCT
; ;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; offset (wrt FDSTRUCT.JP)  description
;
;  8..13                    mutex
; 14..15                    reserved
;   16                      window.x
;   17                      window.width
;   18                      window.y
;   19                      window.height
;   20                      scroll_limit
;   21                      line_spacing
;   22                      temp: cursor ascii code
; 23..24                    temp: fzx_draw mode
; 25..26                    temp: edit x coord
; 27..28                    temp: edit y coord
;   29                      temp: space_expand
;
;   30                      JP
; 31..32                    fzx_draw
; 33..34                    struct fzx_font *
; 35..36                    x coordinate
; 37..38                    y coordinate
; 39..40                    paper.x
; 41..42                    paper.width
; 43..44                    paper.y
; 45..46                    paper.height
; 47..48                    left_margin
;   49                      space_expand
; 50..51                    reserved
;   52                      text colour
;   53                      text colour mask (set bits = keep bgnd)
;   54                      background colour (cls colour)
;   55                      tty_z88dk.call (205)
; 56..57                    tty_z88dk.state
;   58                      tty_z88dk.action
;   59                      tty_z88dk.param_1
;   60                      tty_z88dk.param_2

SECTION code_driver
SECTION code_driver_terminal_output

PUBLIC zx_01_output_fzx_tty_z88dk

EXTERN OTERM_MSG_TTY, STDIO_MSG_FLSH, STDIO_MSG_ICTL

EXTERN zx_01_output_fzx
EXTERN zx_01_output_fzx_tty_z88dk_oterm_msg_tty
EXTERN zx_01_output_fzx_tty_z88dk_stdio_msg_flsh
EXTERN zx_01_output_fzx_tty_z88dk_stdio_msg_ictl

zx_01_output_fzx_tty_z88dk:

   cp OTERM_MSG_TTY
   jp z, zx_01_output_fzx_tty_z88dk_oterm_msg_tty

   cp STDIO_MSG_FLSH
   jp z, zx_01_output_fzx_tty_z88dk_stdio_msg_flsh
   
   cp STDIO_MSG_ICTL
   jp z, zx_01_output_fzx_tty_z88dk_stdio_msg_ictl
   
   jp zx_01_output_fzx         ; forward to library
