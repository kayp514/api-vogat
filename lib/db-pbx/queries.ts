'use server'

import prisma from '@/lib/pbx-prisma-client';
import type { CreateAuthUserInput, AuthUserWithTenant, Domain } from '@/lib/db-pbx/types';


export async function createAuthUser(data: CreateAuthUserInput): Promise<AuthUserWithTenant> {
    if (!data) {
        throw new Error('uid and email are required to create auth user');
    }

    try {
        const user = await prisma.auth_user.create({
            data: {
                uid: data.uid,
                email: data.email,
                displayName: data.displayName ?? null,
                firstName: data.firstName ?? null,
                lastName: data.lastName ?? null,
                avatar: data.avatar ?? null,
                phoneNumber: data.phoneNumber ?? null,
                tenantId: data.tenantId ?? 'default',
                isSuperuser: data.isSuperuser ?? false,
                isAdmin: data.isAdmin ?? false,
                isStaff: data.isStaff ?? false,
                disabled: data.disabled ?? false,
                lastSignInAt: data.lastSignInAt ?? null,
                ...(data.createdAt && { createdAt: data.createdAt }),
            },
            include: {
                auth_tenant: true,
            },
        });

        return user;
    } catch (error) {
        if (error instanceof Error && error.message.includes('Unique constraint')) {
            throw new Error(`User with email ${data.email} or uid ${data.uid} already exists`);
        }
        throw new Error(error instanceof Error ? error.message : 'Failed to create auth user');
    }
}

/**
 * Find auth_user by email (used to check if invite exists for signup)
 */
export async function findAuthUserByEmail(email: string): Promise<AuthUserWithTenant | null> {
    return prisma.auth_user.findUnique({
        where: { email },
        include: { auth_tenant: true },
    });
}

/**
 * Find auth_user by uid
 */
export async function findAuthUserByUid(uid: string): Promise<AuthUserWithTenant | null> {
    return prisma.auth_user.findUnique({
        where: { uid },
        include: { auth_tenant: true },
    });
}

/**
 * Update auth_user (e.g., after consuming invite, setting admin flags)
 */
export async function updateAuthUser(
    uid: string,
    data: Partial<Omit<CreateAuthUserInput, 'uid' | 'email'>>
): Promise<AuthUserWithTenant> {
    return prisma.auth_user.update({
        where: { uid },
        data: {
            ...(data.displayName !== undefined && { displayName: data.displayName }),
            ...(data.firstName !== undefined && { firstName: data.firstName }),
            ...(data.lastName !== undefined && { lastName: data.lastName }),
            ...(data.avatar !== undefined && { avatar: data.avatar }),
            ...(data.phoneNumber !== undefined && { phoneNumber: data.phoneNumber }),
            ...(data.isSuperuser !== undefined && { isSuperuser: data.isSuperuser }),
            ...(data.isAdmin !== undefined && { isAdmin: data.isAdmin }),
            ...(data.isStaff !== undefined && { isStaff: data.isStaff }),
            ...(data.disabled !== undefined && { disabled: data.disabled }),
            ...(data.lastSignInAt !== undefined && { lastSignInAt: data.lastSignInAt }),
        },
        include: { auth_tenant: true },
    });
}

// ============================================================================
// INVITE QUERIES
// ============================================================================

/**
 * Check if a pending (unused, not expired) invite exists for an email
 * Used by Firebase Cloud Function to determine if signup is via invite or direct owner signup
 * 
 * @returns Invite with auth_group info, or null if no valid invite found
 */
export async function findPendingInviteByEmail(email: string) {
    return prisma.invite.findFirst({
        where: {
            email: email.toLowerCase(),
            usedAt: null,
            expiresAt: {
                gt: new Date(), // Not expired
            },
        },
        include: {
            auth_group: true,
            pbx_domain: {
                include: {
                    subscription: true,
                },
            },
        },
        orderBy: {
            createdAt: 'desc', // Get most recent if multiple invites
        },
    });
}

/**
 * Find invite by token (for consuming invite during onboarding)
 */
export async function findInviteByToken(token: string) {
    return prisma.invite.findUnique({
        where: { token },
        include: {
            auth_group: true,
            pbx_domain: {
                include: {
                    subscription: true,
                },
            },
        },
    });
}

/**
 * Mark invite as used (after creating pbx_users record)
 */
export async function consumeInvite(token: string, usedAt: Date = new Date()) {
    return prisma.invite.update({
        where: { token },
        data: { usedAt },
        include: {
            auth_group: true,
            pbx_domain: true,
        },
    });
}


export async function getDomain(id: string): Promise<Domain | null> {
    try {
        return await prisma.pbx_domains.findUnique({
            where: { id },
            include: {
                domain_settings: true,
            }
        });
    } catch (error) {
        console.error('Error fetching domain:', error)
        throw error
    }
}


/**
 * Update domain switch provisioning status
 * Used by Cloud Run provisioning service to update homeSwitch, switchStatus, ipAddress
 */
export async function updateDomainSwitchStatus(
    id: string,
    data: {
        switchStatus: string;
        homeSwitch?: string;
        ipAddress?: string;
    }
): Promise<{
    id: string;
    name: string;
    homeSwitch: string | null;
    switchStatus: string;
    ipAddress: string | null;
}> {
    return await prisma.pbx_domains.update({
        where: { id },
        data: {
            switchStatus: data.switchStatus,
            ...(data.homeSwitch !== undefined && { homeSwitch: data.homeSwitch }),
            ...(data.ipAddress !== undefined && { ipAddress: data.ipAddress }),
            updated: new Date(),
        },
        select: {
            id: true,
            name: true,
            homeSwitch: true,
            switchStatus: true,
            ipAddress: true,
        },
    });
}