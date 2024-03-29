"""initial db

Revision ID: 2de96c2c4ad0
Revises: 
Create Date: 2022-06-13 20:48:02.313894

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '2de96c2c4ad0'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('account_types',
    sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
    sa.Column('name', sa.String(), nullable=False),
    sa.Column('price', sa.Numeric(), nullable=False),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('name')
    )
    op.create_table('baits',
    sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
    sa.Column('name', sa.String(), nullable=False),
    sa.Column('artificial', sa.Boolean(), nullable=False),
    sa.Column('size', sa.Numeric(), nullable=True),
    sa.Column('color', sa.String(), nullable=True),
    sa.Column('description', sa.String(), nullable=True),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('name', 'size', 'color')
    )
    op.create_table('fishing_gear',
    sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
    sa.Column('rod', sa.String(), nullable=False),
    sa.Column('reel', sa.String(), nullable=True),
    sa.Column('line', sa.String(), nullable=True),
    sa.Column('hook', sa.String(), nullable=True),
    sa.Column('leader', sa.String(), nullable=True),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_table('fishing_outings',
    sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
    sa.Column('date', sa.Date(), nullable=False),
    sa.Column('trip_type', sa.String(), nullable=False),
    sa.Column('water', sa.String(), nullable=True),
    sa.Column('description', sa.String(), nullable=True),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_table('fishing_spots',
    sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
    sa.Column('latitude', sa.Numeric(), nullable=False),
    sa.Column('longitude', sa.Numeric(), nullable=False),
    sa.Column('name', sa.String(), nullable=False),
    sa.Column('description', sa.String(), nullable=True),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('latitude', 'longitude')
    )
    op.create_table('priviledges',
    sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
    sa.Column('name', sa.String(), nullable=False),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('name')
    )
    op.create_table('ranks',
    sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
    sa.Column('name', sa.String(), nullable=False),
    sa.Column('rank_number', sa.Integer(), nullable=False),
    sa.Column('description', sa.String(), nullable=False),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('name'),
    sa.UniqueConstraint('rank_number')
    )
    op.create_table('account_priviledges',
    sa.Column('account_type_id', sa.Integer(), nullable=False),
    sa.Column('priviledge_id', sa.Integer(), nullable=False),
    sa.ForeignKeyConstraint(['account_type_id'], ['account_types.id'], ondelete='CASCADE'),
    sa.ForeignKeyConstraint(['priviledge_id'], ['priviledges.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('account_type_id', 'priviledge_id')
    )
    op.create_table('anglers',
    sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
    sa.Column('name', sa.String(length=30), nullable=False),
    sa.Column('rank_id', sa.Integer(), nullable=False),
    sa.ForeignKeyConstraint(['rank_id'], ['ranks.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('name')
    )
    op.create_table('fished_spots',
    sa.Column('fishing_outing_id', sa.Integer(), nullable=False),
    sa.Column('fishing_spot_id', sa.Integer(), nullable=False),
    sa.ForeignKeyConstraint(['fishing_outing_id'], ['fishing_outings.id'], ),
    sa.ForeignKeyConstraint(['fishing_spot_id'], ['fishing_spots.id'], ),
    sa.PrimaryKeyConstraint('fishing_outing_id', 'fishing_spot_id')
    )
    op.create_table('fishes',
    sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
    sa.Column('species', sa.String(), nullable=False),
    sa.Column('datetime_caught', sa.DateTime(), nullable=False),
    sa.Column('weight', sa.Numeric(), nullable=True),
    sa.Column('length', sa.Numeric(), nullable=True),
    sa.Column('description', sa.String(), nullable=True),
    sa.Column('bait_id', sa.Integer(), nullable=True),
    sa.Column('fishing_gear_id', sa.Integer(), nullable=True),
    sa.Column('fishing_spot_id', sa.Integer(), nullable=True),
    sa.ForeignKeyConstraint(['bait_id'], ['baits.id'], ),
    sa.ForeignKeyConstraint(['fishing_gear_id'], ['fishing_gear.id'], ondelete='SET NULL'),
    sa.ForeignKeyConstraint(['fishing_spot_id'], ['fishing_spots.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_table('fishing_conditions',
    sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
    sa.Column('weather', sa.String(), nullable=False),
    sa.Column('tide_phase', sa.String(), nullable=False),
    sa.Column('time_stamp', sa.DateTime(), nullable=False),
    sa.Column('current_flow', sa.String(), nullable=True),
    sa.Column('current_speed', sa.Numeric(), nullable=True),
    sa.Column('moon_phase', sa.String(length=20), nullable=True),
    sa.Column('wind_direction', sa.String(length=3), nullable=True),
    sa.Column('wind_speed', sa.Integer(), nullable=True),
    sa.Column('pressure_yesterday', sa.Numeric(), nullable=True),
    sa.Column('pressure_today', sa.Numeric(), nullable=True),
    sa.Column('fishing_spot_id', sa.Integer(), nullable=False),
    sa.ForeignKeyConstraint(['fishing_spot_id'], ['fishing_spots.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_table('fish_caught',
    sa.Column('anglers_id', sa.Integer(), nullable=False),
    sa.Column('fishes_id', sa.Integer(), nullable=False),
    sa.ForeignKeyConstraint(['anglers_id'], ['anglers.id'], ondelete='CASCADE'),
    sa.ForeignKeyConstraint(['fishes_id'], ['fishes.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('anglers_id', 'fishes_id')
    )
    op.create_table('outings_fished',
    sa.Column('fishing_outing_id', sa.Integer(), nullable=False),
    sa.Column('angler_id', sa.Integer(), nullable=False),
    sa.ForeignKeyConstraint(['angler_id'], ['anglers.id'], ondelete='CASCADE'),
    sa.ForeignKeyConstraint(['fishing_outing_id'], ['fishing_outings.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('fishing_outing_id', 'angler_id')
    )
    op.create_table('user_accounts',
    sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
    sa.Column('username', sa.String(length=30), nullable=False),
    sa.Column('password', sa.String(length=256), nullable=False),
    sa.Column('account_type_id', sa.Integer(), nullable=False),
    sa.Column('angler_id', sa.Integer(), nullable=True),
    sa.ForeignKeyConstraint(['account_type_id'], ['account_types.id'], ondelete='CASCADE'),
    sa.ForeignKeyConstraint(['angler_id'], ['anglers.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('username')
    )
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_table('user_accounts')
    op.drop_table('outings_fished')
    op.drop_table('fish_caught')
    op.drop_table('fishing_conditions')
    op.drop_table('fishes')
    op.drop_table('fished_spots')
    op.drop_table('anglers')
    op.drop_table('account_priviledges')
    op.drop_table('ranks')
    op.drop_table('priviledges')
    op.drop_table('fishing_spots')
    op.drop_table('fishing_outings')
    op.drop_table('fishing_gear')
    op.drop_table('baits')
    op.drop_table('account_types')
    # ### end Alembic commands ###
