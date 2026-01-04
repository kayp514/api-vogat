import type { CreateAuthUserInput } from '@/lib/db-pbx/types';
import { NextResponse } from 'next/server'
import { createAuthUser } from '@/lib/db-pbx/queries';

const DEFAULT_TENANT_ID = 'default'

export async function POST(request: Request) {
    try {
        const body = await request.json();

        const {
            uid,
            email,
            displayName,
            firstName,
            lastName,
            avatar,
            phoneNumber,
            tenantId,
            isSuperuser,
            isAdmin,
            isStaff,
            disabled,
            createdAt,
            lastSignInAt
        } = body

        if (!uid || !email) {
            return NextResponse.json(
                {
                    success: false,
                    error: {
                        code: 'INVALID_INPUT',
                        message: 'uid and email are required'
                    }
                },
                { status: 400 }
            )
        }

        const userData: CreateAuthUserInput = {
            uid,
            email,
            displayName: displayName ?? null,
            firstName: firstName ?? null,
            lastName: lastName ?? null,
            avatar: avatar ?? null,
            phoneNumber: phoneNumber ?? null,
            tenantId: tenantId ?? DEFAULT_TENANT_ID,
            isSuperuser: isSuperuser ?? false,
            isAdmin: isAdmin ?? false,
            isStaff: isStaff ?? false,
            disabled: disabled ?? false,
            createdAt: createdAt ? new Date(createdAt) : null,
            lastSignInAt: lastSignInAt ? new Date(lastSignInAt) : null,
        }

        const res = await createAuthUser(userData);

        return NextResponse.json(
            {
                success: true,
                user: res
            },
            { status: 201 }
        )


    } catch (error) {
        console.error('Create user API error:', error)

        if (error instanceof Error && error.message.includes('already exists')) {
            return NextResponse.json(
                {
                    success: false,
                    error: {
                        code: 'USER_EXISTS',
                        message: error.message
                    }
                },
                { status: 409 }
            )
        }

        return NextResponse.json(
            {
                success: false,
                error: {
                    code: 'INTERNAL_ERROR',
                    message: error instanceof Error ? error.message : 'Failed to create user'
                }
            },
            { status: 500 }
        )
    }
}