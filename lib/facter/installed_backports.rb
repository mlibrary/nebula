# frozen_string_literal: true

Facter.add(:installed_backports) do
  setcode do
    Facter::Core::Execution.execute(
      "dpkg -l | awk '/^.i .*~bpo/ { print $2 }'",
    ).strip.split("\n").map { |package| package.sub(%r{:amd64$}, '') }
  end
end
