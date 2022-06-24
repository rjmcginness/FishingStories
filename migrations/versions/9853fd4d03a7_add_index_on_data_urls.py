"""add index on data_urls

Revision ID: 9853fd4d03a7
Revises: 0fe4d91dd7e6
Create Date: 2022-06-24 01:29:30.265108

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '9853fd4d03a7'
down_revision = '0fe4d91dd7e6'
branch_labels = None
depends_on = None

index = '''
            CREATE INDEX data_urls_hash_index ON data_urls USING HASH (data_type);
        '''

def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    
    # MANUALLY ADDED 6/23/2022
    op.execute(index)
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    
    # MANUALLY ADDED 6/23/2022
    op.execute('DROP INDEX data_urls_hash_index;')
    # ### end Alembic commands ###
