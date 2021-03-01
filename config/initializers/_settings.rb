#Set Round mode for all financial calculations
BigDecimal.mode(BigDecimal::ROUND_MODE, :banker)

# Ignore Prawn UTF-8 Warnings as german chars are supported
Prawn::Font::AFM.hide_m17n_warning = true
