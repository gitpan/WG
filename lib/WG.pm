package WG;

use strict;
use warnings;

use Moose;

use Config::General;
use Cwd;
use File::Spec;
use Log::Any qw/$log/;


use WG::Dev;

BEGIN{
  # The test compatible File::Share
  eval{ require File::Share; File::Share->import('dist_dir'); };
  if( $@ ){
    # The production only File::ShareDir
    require File::ShareDir;
    File::ShareDir->import('dist_dir');
  }
};

=head1 NAME

WG - The Wigoot application

=head1 ATTRIBUTES

config_file - The config file. Not mandatory. Will try to find a wigoot.conf in /etc/wigoot/ or in the current dir

config - A hash of the whole config.

developer - a WG::Dev object

share_dir - The share directory of this application (contains resource files).

=cut

has 'config_file' => ( is => 'ro' , isa => 'Str' , lazy_build => 1 );

has 'config' => ( is => 'ro' , isa => 'HashRef' , lazy_build => 1 );

has 'share_dir' => ( is => 'ro' , isa => 'Str', lazy_build => 1 );

has 'developer' => ( is => 'ro' , isa => 'WG::Dev' , lazy_build => 1 );

{
  my $ETC_CONFIG = '/etc/wigoot/wigoot-conf';

  sub _build_config_file{
    my ($self) = @_;
    if( -e $ETC_CONFIG ){
      $log->info("Config file is $ETC_CONFIG");
      return $ETC_CONFIG;
    }

    my $cwd_based = Cwd::abs_path('wigoot.conf');
    unless( -e $cwd_based ){
      confess("No $cwd_based file found. Please specify the config file");
    }
    return $cwd_based;
  }
}

sub _build_config{
  my ($self) = @_;
  my $file = $self->config_file();
  $log->info("Building config from '$file'");
  my $cf = Config::General->new($file) or confess("Cannot load '$file'");
  return { $cf->getall() };
}

sub _build_share_dir{
  my ($self) = @_;
  my $file_based_dir = File::Spec->rel2abs(__FILE__);
  my $package = __PACKAGE__;

  $file_based_dir =~ s|lib/$package.+||;
  $file_based_dir .= 'share/';
  if( -d $file_based_dir ){

    my $real_sharedir = Cwd::realpath($file_based_dir);
    unless( $real_sharedir ){
      confess("Could not build Cwd::realpath from '$file_based_dir'");
    }
    $real_sharedir .= '/';

    $log->info("Will use file based shared directory '$real_sharedir'");
    return $real_sharedir;
  }

  my $dist_based_dir = Cwd::realpath(dist_dir(__PACKAGE__));

  my $real_sharedir = Cwd::realpath($dist_based_dir);
  unless( $real_sharedir ){
    confess("Could not build Cwd::realpath from '$dist_based_dir'");
  }

  $real_sharedir .= '/';

  $log->info("Will use File::Share based directory ".$real_sharedir);
  return $real_sharedir;
}

sub _build_developer{
  my ($self) = @_;
  return WG::Dev->new({ wg => $self });
}


__PACKAGE__->meta->make_immutable();
