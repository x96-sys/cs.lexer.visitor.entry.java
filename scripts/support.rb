def cml(str, lower: false)
  parts = str.split(/_| /).map(&:capitalize)
  result = parts.join
  lower ? result.sub(/^./, &:downcase) : result
end

def kinds
  {
	"0" => %w[null soh stx etx eot enq ack bel bs ht lf vt ff cr so si],
	"1" => %w[dle dc1 dc2 dc3 dc4 nak syn etb can em sub esc fs gs rs us],
	"2" => %w[space exclamation_mark quotation_mark number_sign dollar_sign percent_sign ampersand apostrophe left_parenthesis right_parenthesis asterisk plus comma hyphen_minus full_stop solidus],
	"3" => %w[digit_zero digit_one digit_two digit_three digit_four digit_five digit_six digit_seven digit_eight digit_nine colon semicolon less_than_sign equals greater_than_sign question_mark],
	"4" => %w[commercial_at latin_capital_letter_a latin_capital_letter_b latin_capital_letter_c latin_capital_letter_d latin_capital_letter_e latin_capital_letter_f latin_capital_letter_g latin_capital_letter_h latin_capital_letter_i latin_capital_letter_j latin_capital_letter_k latin_capital_letter_l latin_capital_letter_m latin_capital_letter_n latin_capital_letter_o],
	"5" => %w[latin_capital_letter_p latin_capital_letter_q latin_capital_letter_r latin_capital_letter_s latin_capital_letter_t latin_capital_letter_u latin_capital_letter_v latin_capital_letter_w latin_capital_letter_x latin_capital_letter_y latin_capital_letter_z left_square_bracket reverse_solidus right_square_bracket circumflex_accent low_line],
	"6" => %w[grave_accent latin_small_letter_a latin_small_letter_b latin_small_letter_c latin_small_letter_d latin_small_letter_e latin_small_letter_f latin_small_letter_g latin_small_letter_h latin_small_letter_i latin_small_letter_j latin_small_letter_k latin_small_letter_l latin_small_letter_m latin_small_letter_n latin_small_letter_o],
	"7" => %w[latin_small_letter_p latin_small_letter_q latin_small_letter_r latin_small_letter_s latin_small_letter_t latin_small_letter_u latin_small_letter_v latin_small_letter_w latin_small_letter_x latin_small_letter_y latin_small_letter_z left_curly_bracket vertical_line right_curly_bracket tilde delete],
  }
end
