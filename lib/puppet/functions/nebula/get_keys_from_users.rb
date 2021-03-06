# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Get a list of key hashes from user data.
Puppet::Functions.create_function(:'nebula::get_keys_from_users') do
  # Input userdata from a hiera lookup.
  #
  # @param hiera_sudoers Hiera path to lookup
  # @param default_host Default hostname to put as a comment (set to ''
  #   to set no hostname)
  # @return [Array[Hash[String, String]]] List of key hashes with values
  #   for type, key, and comment.
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
  # @param sudoers Hash of hashes
  # @param default_host Default hostname to put as a comment (set to ''
  #   to set no hostname)
  # @return [Array[Hash[String, String]]] List of key hashes with values
  #   for type, key, and comment.
  #
  # @example With a single user
  #   nebula::get_keys_from_users({
  #     'username' => {
  #       'type' => 'ssh-rsa',
  #       'key'  => 'AAAAAAAA',
  #       'host' => 'localhost',
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
      host = userdata['host'] || default_host

      comment = if host == ''
                  username
                else
                  "#{username}@#{host}"
                end

      keys << {
        'type'    => userdata['type'],
        'data'    => userdata['key'].gsub(%r{\s+}, ''),
        'comment' => comment,
      }
    end

    keys
  end
end
