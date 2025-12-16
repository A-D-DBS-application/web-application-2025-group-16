from __future__ import annotations

from functools import wraps
from typing import Callable, Optional

from flask import g, jsonify, redirect, session, url_for

from session_context import (
    get_active_group_record,
    get_current_group_snapshot,
    is_current_user_host,
    list_user_groups,
)


def login_required(view: Optional[Callable] = None, *, response: str = "html") -> Callable:
    """Ensure the request originates from an authenticated session."""

    def decorator(func: Callable) -> Callable:
        @wraps(func)
        def wrapper(*args, **kwargs):
            user_id = session.get("user_id")
            if not user_id:
                if response == "json":
                    return jsonify({"error": "Niet ingelogd"}), 401
                return redirect(url_for("auth.login"))
            g.user_id = user_id
            return func(*args, **kwargs)

        return wrapper

    if view is not None:
        return decorator(view)
    return decorator


def with_group_context(
    view: Optional[Callable] = None,
    *,
    response: str = "html",
    require_active: bool = False,
    require_host: bool = False,
) -> Callable:
    """Load commonly used group context into flask.g and enforce access rules."""

    def decorator(func: Callable) -> Callable:
        @wraps(func)
        def wrapper(*args, **kwargs):
            snapshot = get_current_group_snapshot()
            active_group = get_active_group_record() if snapshot else None

            g.group_snapshot = snapshot
            g.active_group = active_group
            g.user_groups = list_user_groups()
            g.is_host = is_current_user_host()

            if require_active and not snapshot:
                if response == "json":
                    return jsonify({"error": "Geen actieve groep"}), 404
                return redirect(url_for("main.home"))

            if require_host and not g.is_host:
                if response == "json":
                    return jsonify({"error": "Alleen hosts"}), 403
                return redirect(url_for("main.home"))

            return func(*args, **kwargs)

        return wrapper

    if view is not None:
        return decorator(view)
    return decorator
