package WG::Test;

use Moose;
extends qw/WG/;

sub _build_config_file{
  my ($self) = @_;
  return $self->share_dir().'/test/wigoot.conf';
}

__PACKAGE__->meta->make_immutable();
