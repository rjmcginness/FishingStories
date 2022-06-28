"""added image storage to fish

Revision ID: 0e28d710807a
Revises: 981fb243334b
Create Date: 2022-06-23 01:38:31.095487

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '0e28d710807a'
down_revision = '981fb243334b'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('fishes', sa.Column('image', sa.LargeBinary(), nullable=True))
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('fishes', 'image')
    # ### end Alembic commands ###