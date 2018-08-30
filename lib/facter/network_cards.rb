# frozen_string_literal: true

Facter.add(:network_cards) do
  setcode do
    Facter::Core::Execution.execute(
      "lspci | grep Ethernet | cut -f 3 -d ':'",
    ).strip.split("\n")
  end
end
