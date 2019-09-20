# frozen_string_literal: true

Facter.add(:vm_guests) do
  setcode do
    if File.exist?('/usr/bin/virsh')
      Facter::Core::Execution.execute(
        '/usr/bin/virsh list --name',
      ).strip.split("\n")
    else
      []
    end
  end
end
