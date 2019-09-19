# frozen_string_literal: true

Facter.add(:ruby_versions) do
  setcode do
    if File.exist?('/etc/profile.d/rbenv.sh')
      Facter::Core::Execution.execute(
        "source /etc/profile.d/rbenv.sh; rbenv versions --bare --skip-aliases",
      ).strip.split("\n")
    else
      []
    end
  end
end
