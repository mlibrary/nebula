# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::get_keys_from_users
#
# Get a list of key hashes from user data.
Puppet::Functions.create_function(:'nebula::get_keys_from_users') do
  # Input userdata from a hiera lookup.
  #
  # @param hiera_sudoers Hiera path to lookup
  # @param default_host Default hostname to put as a comment (set to ''
  #   to set no hostname)
  #
  # @example Extract from nebula::users::sudoers
  #   nebula::get_keys_from_users('nebula::users::sudoers')
  dispatch :get_from_hiera do
    required_param 'String', :hiera_sudoers
    optional_param 'String', :default_host
    return_type 'Array[Hash[String, String]]'
  end

  # Input userdata directly from a hash.
  #
  # @param sudoers Hash of hashes, some of which may contain a hash
  #   under the 'auth' key.
  # @param default_host Default hostname to put as a comment (set to ''
  #   to set no hostname)
  #
  # @example With a single user
  #   nebula::get_keys_from_users({
  #     'username' => {
  #       'auth' => {
  #         'type' => 'ssh-rsa',
  #         'key'  => 'AAAAAAAA',
  #         'host' => 'localhost',
  #       },
  #     },
  #   }) => [{'type'    => 'ssh-rsa',
  #           'key'     => 'AAAAAAAA',
  #           'comment' => 'username@localhost'}]
  dispatch :get_from_hash do
    required_param 'Hash[String, Hash]', :sudoers
    optional_param 'String', :default_host
    return_type 'Array[Hash[String, String]]'
  end

  def get_from_hiera(hiera_sudoers, default_host = '')
    get_from_hash(call_function('lookup', hiera_sudoers), default_host)
  end

  def get_from_hash(sudoers, default_host = '')
    keys = []

    sudoers.each do |username, userdata|
      next unless userdata.key? 'auth'
      auth = userdata['auth']
      host = auth['host'] || default_host

      comment = if host == ''
                  username
                else
                  "#{username}@#{host}"
                end

      keys << {
        'type'    => userdata['auth']['type'],
        'data'    => userdata['auth']['key'].gsub(%r{\s+}, ''),
        'comment' => comment,
      }
    end

    keys
  end
end
