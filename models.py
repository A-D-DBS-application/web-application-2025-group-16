from sqlalchemy import (
    create_engine,
    Column,
    Integer,
    String,
    Float,
    DateTime,
    Date,
    ForeignKey,
    Text,
    PrimaryKeyConstraint,
    func,
    Boolean,
)
from sqlalchemy.orm import declarative_base, relationship, sessionmaker
import os
from datetime import datetime
from dotenv import load_dotenv  # <--- TOEVOEGEN

# Dit zorgt dat hij je .env bestand (met het wachtwoord) daadwerkelijk leest
load_dotenv()

# Supabase PostgreSQL URL: set in .env as DATABASE_URL
# Format: postgresql://user:password@host:5432/dbname
# Fallback: SQLite for dev
SUPABASE_DATABASE_URL = os.environ.get("DATABASE_URL")
if SUPABASE_DATABASE_URL:
    DATABASE_URL = SUPABASE_DATABASE_URL
else:
    DATABASE_URL = "sqlite:///dev.db"

engine = create_engine(DATABASE_URL, echo=False, future=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)

Base = declarative_base()


class Leden(Base):
    __tablename__ = "Leden"
    ledenid = Column(Integer, primary_key=True, autoincrement=True)
    email = Column(String, unique=True, nullable=False)
    voornaam = Column(String)
    achternaam = Column(String)
    GSM = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)


class Groep(Base):
    __tablename__ = "Groep"
    groep_id = Column(Integer, primary_key=True, autoincrement=True)
    groep_naam = Column(String, nullable=False)
    omschrijving = Column(Text)
    invite_code = Column(String, unique=True)
    owner_lid_id = Column(Integer, ForeignKey("Leden.ledenid"))
    created_at = Column(DateTime, default=datetime.utcnow)
    portefeuille_id = Column(Integer)
    instap_nav_pct = Column(Float, default=0.0)
    instap_liq_pct = Column(Float, default=0.0)
    uitstap_nav_pct = Column(Float, default=0.0)
    uitstap_liq_pct = Column(Float, default=0.0)
    liq_per_lid = Column(Boolean, default=False)

    owner = relationship("Leden")


class GroepLeden(Base):
    __tablename__ = "groep_leden"
    __table_args__ = (PrimaryKeyConstraint("groep_id", "ledenid", name="groep_leden_pkey"),)

    groep_id = Column(Integer, ForeignKey("Groep.groep_id"), nullable=False)
    ledenid = Column(Integer, ForeignKey("Leden.ledenid"), nullable=False)
    rol = Column(String, default="member")
    created_at = Column(DateTime, default=datetime.utcnow)

    group = relationship("Groep")
    leden = relationship("Leden")


class Activa(Base):
    __tablename__ = "activa"

    ticker = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    sector = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    portfolio_positions = relationship("Portefeuille", back_populates="asset")


class Portefeuille(Base):
    __tablename__ = "Portefeuille"

    port_id = Column(Integer, primary_key=True, autoincrement=True)
    ticker = Column(String, ForeignKey("activa.ticker"), nullable=False)
    quantity = Column(Float, default=0.0)
    avg_price = Column(Float, default=0.0)
    groep_id = Column(Integer, ForeignKey("Groep.groep_id"), nullable=False)
    transactiekost = Column(Float, default=0.0)

    asset = relationship("Activa", back_populates="portfolio_positions")
    group = relationship("Groep")


class Transacties(Base):
    __tablename__ = "Transacties"

    transactie_id = Column(Integer, primary_key=True, autoincrement=True)
    datum_tr = Column(Date, nullable=False)
    type = Column(String, nullable=False)
    ticker = Column(String, ForeignKey("activa.ticker"), nullable=False)
    aantal = Column(Float, nullable=False)
    koers = Column(Float, nullable=False)
    wisselkoers = Column(Float, nullable=True)
    munt = Column(String, nullable=False, default="EUR")
    portefeuille_id = Column(Integer, ForeignKey("Portefeuille.port_id"))

    asset = relationship("Activa")
    portfolio = relationship("Portefeuille")


class Kas(Base):
    __tablename__ = "Kas"
    kas_id = Column(Integer, primary_key=True, autoincrement=True)
    groep_id = Column(Integer, ForeignKey("Groep.groep_id"))
    amount = Column(Float)
    type = Column(String)
    description = Column(Text)
    date = Column(DateTime, default=datetime.utcnow)
    created_by = Column(Integer, ForeignKey("Leden.ledenid"))


class GroepAanvragen(Base):
    __tablename__ = "groepsaanvragen"
    id = Column(Integer, primary_key=True, autoincrement=True)
    groep_id = Column(Integer, ForeignKey("Groep.groep_id"))
    ledenid = Column(Integer, ForeignKey("Leden.ledenid"))
    type = Column(String)
    status = Column(String, default="pending")
    processed_by = Column(Integer, ForeignKey("Leden.ledenid"))
    created_at = Column(DateTime, default=datetime.utcnow)


class Wisselkoersen(Base):
    __tablename__ = "Wisselkoersen"

    munt = Column(String, primary_key=True)
    wk = Column(Float, nullable=False)



def init_db():
    """Create tables (development)."""
    Base.metadata.create_all(bind=engine)


__all__ = [
    "engine",
    "SessionLocal",
    "Base",
    "Leden",
    "Groep",
    "GroepLeden",
    "Activa",
    "Portefeuille",
    "Transacties",
    "Kas",
    "GroepAanvragen",
    "Wisselkoersen",
    "init_db",
]

# Als je dit bestand direct runt, voer dan de functie uit
if __name__ == "__main__":
    init_db()