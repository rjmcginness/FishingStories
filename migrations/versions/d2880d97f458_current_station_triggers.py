"""current station triggers

Revision ID: d2880d97f458
Revises: ed770a6c412f
Create Date: 2022-06-21 00:26:08.179924

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'd2880d97f458'
down_revision = 'ed770a6c412f'
branch_labels = None
depends_on = None


find_nearest_current = '''
                           CREATE FUNCTION find_nearest()
                           RETURNS TRIGGER AS $$
                           BEGIN
                               WITH distances AS (
                                   SELECT id,
                                   MIN(3963 * ACOS(SIN(cs.latitude) * SIN(NEW.latitude) + 
                                                COS(cs.latitude) * COS(NEW.latitude) *
                                                COS(NEW.latitude - cs.latitude)
                                               )
                                    ) AS dist FROM current_stations cs
                                ) INSERT INTO fishing_spots (nearest_known_id)
                                  SELECT id FROM distances WHERE dist=(SELECT MIN(dist) from distances);
                           RETURN NEW;
                           END;
                           $$ LANGUAGE PLPGSQL;
                    '''

trigger = '''
              CREATE TRIGGER insert_nearest
              AFTER INSERT ON fishing_spots
              FOR EACH ROW EXECUTE FUNCTION find_nearest();
          '''

# event.listen(FishingSpot.__table__,
#              'after_create',
#              find_nearest_current.execute_if(dialect='postgresql')
# )

# event.listen(FishingSpot.__table__,
#              'after_create',
#              trigger.execute_if(dialect='postgresql')
# )

def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('current_stations',
    sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
    sa.Column('name', sa.String(length=280), nullable=False),
    sa.Column('latitude', sa.Numeric(), nullable=False),
    sa.Column('longitude', sa.Numeric(), nullable=False),
    sa.Column('current_url_id', sa.Integer(), nullable=False),
    sa.ForeignKeyConstraint(['current_url_id'], ['data_urls.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('name')
    )
    op.add_column('fishing_spots', sa.Column('current_station_id', sa.Integer(), nullable=True))
    op.drop_constraint('fishing_spots_current_url_id_fkey', 'fishing_spots', type_='foreignkey')
    op.create_foreign_key(None, 'fishing_spots', 'current_stations', ['current_station_id'], ['id'])
    op.drop_column('fishing_spots', 'current_url_id')
    
    # ADDED MANUALLY 6/20/2022
    op.execute(find_nearest_current)
    op.execute(trigger)
    
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('fishing_spots', sa.Column('current_url_id', sa.INTEGER(), autoincrement=False, nullable=True))
    op.drop_constraint(None, 'fishing_spots', type_='foreignkey')
    op.create_foreign_key('fishing_spots_current_url_id_fkey', 'fishing_spots', 'data_urls', ['current_url_id'], ['id'], ondelete='CASCADE')
    op.drop_column('fishing_spots', 'current_station_id')
    op.drop_table('current_stations')
    
    # ADDED MANUALLY 6/20/2022
    op.execute('DROP TRIGGER IF EXISTS insert_nearest ON fishing_spots CASCADE;')
    op.execute('DROP FUNCTION find_nearest')
    # ### end Alembic commands ###