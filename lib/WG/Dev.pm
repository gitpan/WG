package WG::Dev;

use Moose;

use Class::Load;
use Cwd;
use Log::Any qw/$log/;

has 'wg' => ( is => 'ro' , isa => 'WG' , required => 1 , weak_ref => 1);

=head1 NAME

WG::Dev - A developer with all the funky actions he can do.

=cut

=head2 schema_dump

Dumps the schema into this code base.

=cut

sub schema_dump{
  my ($self) = @_;
  Class::Load::load_class('DBIx::Class::Schema::Loader');

  my $dump_dir = File::Spec->rel2abs(__FILE__);
  $dump_dir =~ s/[^\/]+\/Dev\.pm//;
  $dump_dir = Cwd::realpath($dump_dir);
  $log->info("Will dump DBIC Schema in $dump_dir as WG::DB");

  my $db_conf = $self->wg->config()->{db};

  DBIx::Class::Schema::Loader::make_schema_at( 'WG::DB',
                                               {
                                                db_schema => [ 'public' ],
                                                qualify_objects => 0,
                                                debug => 1,
                                                dump_directory => $dump_dir,
                                                components => ["FilterColumn", "InflateColumn::DateTime"],
                                               },
                                               [ $db_conf->{dsn}, $db_conf->{username}, $db_conf->{password}
                                                 , {}
                                               ]
                                             );
  return 1;
}


__PACKAGE__->meta->make_immutable();
