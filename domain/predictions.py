from datetime import datetime, timezone


def is_prediction_allowed(kickoff_at: datetime) -> bool:
    # match must not have started yet — treat naive datetimes as UTC
    now = datetime.now(timezone.utc)
    if kickoff_at.tzinfo is None:
        kickoff_at = kickoff_at.replace(tzinfo=timezone.utc)
    return kickoff_at > now
