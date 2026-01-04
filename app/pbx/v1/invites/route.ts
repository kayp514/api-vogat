import { NextResponse } from 'next/server';
import { findPendingInviteByEmail } from '@/lib/db-pbx/queries';

/**
 * GET /api/v1/invites?email=user@example.com
 * 
 * Check if a pending invite exists for an email address.
 * Used by Firebase Cloud Function to determine user role during signup.
 * 
 * Returns:
 * - 200 with invite data if found
 * - 404 if no pending invite exists
 * 
 * Response structure:
 * {
 *   success: true,
 *   invite: {
 *     id, email, domainId, groupId, token, expiresAt,
 *     auth_group: { id, name },
 *     pbx_domain: { id, name, ... }
 *   }
 * }
 */
export async function GET(request: Request) {
    try {
        const { searchParams } = new URL(request.url);
        const email = searchParams.get('email');

        if (!email) {
            return NextResponse.json(
                {
                    success: false,
                    error: {
                        code: 'INVALID_INPUT',
                        message: 'email query parameter is required',
                    },
                },
                { status: 400 }
            );
        }

        // Validate email format
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            return NextResponse.json(
                {
                    success: false,
                    error: {
                        code: 'INVALID_EMAIL',
                        message: 'Invalid email format',
                    },
                },
                { status: 400 }
            );
        }

        const invite = await findPendingInviteByEmail(email);

        if (!invite) {
            return NextResponse.json(
                {
                    success: false,
                    error: {
                        code: 'INVITE_NOT_FOUND',
                        message: 'No pending invite found for this email',
                    },
                },
                { status: 404 }
            );
        }

        // Return invite with group info for Cloud Function to set custom claims
        return NextResponse.json(
            {
                success: true,
                invite: {
                    id: invite.id,
                    email: invite.email,
                    domainId: invite.domainId,
                    groupId: invite.groupId,
                    token: invite.token,
                    expiresAt: invite.expiresAt,
                    createdBy: invite.createdBy,
                    auth_group: {
                        id: invite.auth_group.id,
                        name: invite.auth_group.name,
                    },
                    pbx_domain: {
                        id: invite.pbx_domain.id,
                        name: invite.pbx_domain.name,
                    },
                    subscription: invite.pbx_domain.subscription
                        ? {
                              slug: invite.pbx_domain.subscription.slug,
                              displayName: invite.pbx_domain.subscription.displayName,
                          }
                        : null,
                },
            },
            { status: 200 }
        );
    } catch (error) {
        console.error('Check invite API error:', error);
        return NextResponse.json(
            {
                success: false,
                error: {
                    code: 'INTERNAL_ERROR',
                    message: error instanceof Error ? error.message : 'Failed to check invite',
                },
            },
            { status: 500 }
        );
    }
}
