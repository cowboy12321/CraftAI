from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()


class BaseModel(db.Model):
    __abstract__ = True
    id = db.Column(db.Integer, primary_key=True)

    def save(self):
        db.session.add(self)
        db.session.commit()

    @classmethod
    def get(cls, id):
        return cls.query.get(id)

    def delete(self):
        db.session.delete(self)
        db.session.commit()