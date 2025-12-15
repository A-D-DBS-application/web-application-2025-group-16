from __future__ import annotations

from typing import Any, Dict, List, Optional

from flask import session

from auth import (
    count_group_members,
    get_group_by_id,
    get_membership_for_user,
    get_membership_for_user_in_group,
    list_groups_by_ids,
    list_memberships_for_user,
)


def _ensure_dict(candidate: Any) -> Optional[Dict[str, Any]]:
    return candidate if isinstance(candidate, dict) else None


def get_current_membership() -> Optional[Dict[str, Any]]:
    """Return the active membership for the session user (if any)."""
    user_id = session.get("user_id")
    if not user_id:
        return None

    membership: Optional[Dict[str, Any]] = None
    group_id = session.get("group_id")
    if group_id:
        ok, membership_candidate = get_membership_for_user_in_group(user_id, group_id)
        if ok:
            membership = _ensure_dict(membership_candidate)

    if not membership:
        ok, membership_candidate = get_membership_for_user(user_id)
        if ok:
            membership = _ensure_dict(membership_candidate)
            if membership and "group_id" in membership:
                session["group_id"] = membership["group_id"]

    return membership


def get_current_group_snapshot() -> Optional[Dict[str, Any]]:
    """Return a lightweight snapshot of the active group context."""
    membership = get_current_membership()
    if not membership:
        return None

    group_id = membership.get("group_id")
    if not group_id:
        return None

    ok, group = get_group_by_id(group_id)
    if not ok or not isinstance(group, dict):
        return None

    ok, member_total = count_group_members(group.get("id") or group.get("groep_id"))
    if not ok:
        member_total = 0

    return {
        "id": group.get("id") or group.get("groep_id"),
        "name": group.get("name") or group.get("groep_naam"),
        "code": group.get("invite_code"),
        "member_total": member_total or 0,
        "role": membership.get("role") or membership.get("rol"),
    }


def list_user_groups() -> List[Dict[str, Any]]:
    """Return all groups for the current user along with role metadata."""
    user_id = session.get("user_id")
    if not user_id:
        return []

    ok, memberships = list_memberships_for_user(user_id)
    if not ok or not isinstance(memberships, list):
        return []

    group_ids = [m.get("group_id") for m in memberships if isinstance(m, dict) and m.get("group_id")]
    if not group_ids:
        return []

    ok_groups, groups = list_groups_by_ids(group_ids)
    if not ok_groups or not isinstance(groups, list):
        groups = []

    group_map = {g.get("id"): g for g in groups if isinstance(g, dict) and g.get("id")}
    current_id = session.get("group_id")

    result: List[Dict[str, Any]] = []
    for membership in memberships:
        if not isinstance(membership, dict):
            continue
        gid = membership.get("group_id")
        group = group_map.get(gid)
        if not group:
            continue
        result.append(
            {
                "id": group.get("id"),
                "name": group.get("name") or group.get("groep_naam"),
                "role": membership.get("role") or membership.get("rol"),
                "is_current": gid == current_id,
            }
        )

    return result


def is_current_user_host() -> bool:
    snapshot = get_current_group_snapshot()
    return bool(snapshot and snapshot.get("role") == "host")


def get_active_group_record() -> Optional[Dict[str, Any]]:
    """Return the active group record for the session user."""
    membership = get_current_membership()
    group_id = session.get("group_id") or (membership.get("group_id") if membership else None)
    if not group_id:
        return None

    ok, group = get_group_by_id(group_id)
    if not ok or not isinstance(group, dict):
        return None

    return group